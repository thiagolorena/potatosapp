import { Body, Controller, Get, Param, ParseIntPipe, Post, Put, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { IsInt } from 'class-validator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { PrismaService } from '../prisma/prisma.service';

class StandingDto {
  @IsInt()
  championshipId!: number;

  @IsInt()
  categoryId!: number;

  @IsInt()
  userId!: number;

  @IsInt()
  position!: number;

  @IsInt()
  points!: number;

  @IsInt()
  wins!: number;

  @IsInt()
  poles!: number;

  @IsInt()
  fastestLaps!: number;

  @IsInt()
  races!: number;
}

@Controller('standings')
export class StandingsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('category/:categoryId')
  listByCategory(@Param('categoryId', ParseIntPipe) categoryId: number) {
    return this.prisma.standing.findMany({
      where: { categoryId },
      orderBy: [{ position: 'asc' }, { points: 'desc' }],
      include: {
        user: {
          select: { id: true, name: true, email: true },
        },
        championship: {
          select: { id: true, name: true },
        },
      },
    });
  }

  @Post()
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  create(@Body() dto: StandingDto) {
    return this.prisma.standing.create({ data: dto });
  }

  @Put(':id')
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: StandingDto) {
    return this.prisma.standing.update({ where: { id }, data: dto });
  }
}
