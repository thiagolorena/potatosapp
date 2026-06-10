import { Controller, Get, NotFoundException, Param, ParseIntPipe, Res, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { Response } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { PrismaService } from '../prisma/prisma.service';

@Controller('users')
export class UsersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('pilots')
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  pilots() {
    return this.prisma.user.findMany({
      where: { role: UserRole.PILOT, active: true },
      orderBy: { name: 'asc' },
      select: { id: true, name: true, email: true, phone: true },
    });
  }

  @Get(':id/photo')
  async photo(@Param('id', ParseIntPipe) id: number, @Res() response: Response) {
    const photo = await this.prisma.userPhoto.findUnique({ where: { userId: id } });
    if (!photo) {
      throw new NotFoundException('Foto nao encontrada.');
    }

    response.setHeader('Content-Type', photo.mimeType);
    response.setHeader('Cache-Control', 'public, max-age=86400');
    return response.send(Buffer.from(photo.imageData));
  }
}
