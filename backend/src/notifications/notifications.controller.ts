import { Body, BadRequestException, Controller, Post, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { IsArray, IsBoolean, IsIn, IsInt, IsOptional, IsString, MaxLength } from 'class-validator';
import { CurrentUser } from '../auth/current-user';
import { AuthenticatedUser } from '../auth/current-user';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { PrismaService } from '../prisma/prisma.service';

class SendNotificationDto {
  @IsString()
  @MaxLength(500)
  message!: string;

  @IsBoolean()
  @IsOptional()
  allPilots?: boolean;

  @IsArray()
  @IsInt({ each: true })
  @IsOptional()
  userIds?: number[];
}

class RegisterPushDeviceDto {
  @IsString()
  @MaxLength(512)
  token!: string;

  @IsString()
  @IsIn(['android', 'ios', 'web'])
  platform!: string;
}

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('send')
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async send(@Body() dto: SendNotificationDto) {
    const message = dto.message.trim();
    if (!message) {
      throw new BadRequestException('Informe a mensagem da notificação.');
    }

    const pilots = await this.prisma.user.findMany({
      where: {
        role: UserRole.PILOT,
        active: true,
        ...(dto.allPilots ? {} : { id: { in: dto.userIds ?? [] } }),
      },
      select: { id: true },
    });

    if (!pilots.length) {
      throw new BadRequestException('Selecione pelo menos um piloto ativo.');
    }

    const notification = await this.prisma.notification.create({
      data: {
        message,
        recipients: {
          create: pilots.map((pilot) => ({
            userId: pilot.id,
            status: 'PENDING_PROVIDER',
          })),
        },
      },
      include: { recipients: true },
    });

    const deviceCount = await this.prisma.pushDevice.count({
      where: { active: true, userId: { in: pilots.map((pilot) => pilot.id) } },
    });

    return {
      id: notification.id,
      message: notification.message,
      recipientCount: notification.recipients.length,
      deviceCount,
      status: deviceCount > 0 ? 'QUEUED_PROVIDER_CONFIG_REQUIRED' : 'SAVED_NO_DEVICES',
    };
  }

  @Post('device-token')
  @UseGuards(JwtAuthGuard)
  async registerDevice(@CurrentUser() user: AuthenticatedUser, @Body() dto: RegisterPushDeviceDto) {
    return this.prisma.pushDevice.upsert({
      where: { token: dto.token },
      update: { userId: user.userId, platform: dto.platform, active: true },
      create: { userId: user.userId, token: dto.token, platform: dto.platform },
      select: { id: true, platform: true, active: true },
    });
  }
}
