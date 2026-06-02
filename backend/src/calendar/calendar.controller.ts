import { Body, Controller, Get, Param, ParseIntPipe, Post, Put, UseGuards } from '@nestjs/common';
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
  create(@Body() dto: RaceEventDto) {
    return this.prisma.raceEvent.create({
      data: { ...dto, startsAt: new Date(dto.startsAt) },
    });
  }

  @Put(':id')
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: RaceEventDto) {
    return this.prisma.raceEvent.update({
      where: { id },
      data: { ...dto, startsAt: new Date(dto.startsAt) },
    });
  }
}
