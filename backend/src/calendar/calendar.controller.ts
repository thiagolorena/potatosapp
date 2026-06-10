import { Body, ConflictException, Controller, Get, Param, ParseIntPipe, Post, Put, UseGuards } from '@nestjs/common';
import { EventStatus, UserRole } from '@prisma/client';
import { IsDateString, IsEnum, IsInt, IsOptional, IsString } from 'class-validator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { PrismaService } from '../prisma/prisma.service';

class RaceEventDto {
  @IsInt()
  categoryId!: number;

  @IsString()
  title!: string;

  @IsString()
  trackName!: string;

  @IsString()
  @IsOptional()
  city?: string;

  @IsInt()
  roundNumber!: number;

  @IsDateString()
  startsAt!: string;

  @IsEnum(EventStatus)
  @IsOptional()
  status?: EventStatus;

  @IsString()
  @IsOptional()
  notes?: string;
}

@Controller('calendar')
export class CalendarController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('category/:categoryId')
  listByCategory(@Param('categoryId', ParseIntPipe) categoryId: number) {
    return this.prisma.raceEvent.findMany({
      where: { categoryId },
      orderBy: [{ startsAt: 'asc' }, { roundNumber: 'asc' }],
    });
  }

  @Post()
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async create(@Body() dto: RaceEventDto) {
    await this.ensureRoundIsAvailable(dto.categoryId, dto.roundNumber);
    return this.prisma.raceEvent.create({
      data: { ...dto, startsAt: new Date(dto.startsAt) },
    });
  }

  @Put(':id')
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async update(@Param('id', ParseIntPipe) id: number, @Body() dto: RaceEventDto) {
    await this.ensureRoundIsAvailable(dto.categoryId, dto.roundNumber, id);
    return this.prisma.raceEvent.update({
      where: { id },
      data: { ...dto, startsAt: new Date(dto.startsAt) },
    });
  }

  private async ensureRoundIsAvailable(categoryId: number, roundNumber: number, ignoredEventId?: number) {
    const existing = await this.prisma.raceEvent.findFirst({
      where: {
        categoryId,
        roundNumber,
        ...(ignoredEventId ? { id: { not: ignoredEventId } } : {}),
      },
      select: { id: true },
    });

    if (existing) {
      throw new ConflictException('Ja existe uma etapa com esta rodada nesta categoria.');
    }
  }
}
