import { Body, Controller, Get, Param, ParseIntPipe, Post, Put, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { IsInt, IsOptional } from 'class-validator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { PrismaService } from '../prisma/prisma.service';

class StandingDto {
  @IsInt()
  @IsOptional()
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
  async create(@Body() dto: StandingDto) {
    const championshipId = dto.championshipId ?? (await this.ensureChampionship(dto.categoryId));
    return this.prisma.standing.create({ data: { ...dto, championshipId } });
  }

  @Put(':id')
  @Roles(UserRole.ADMIN)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async update(@Param('id', ParseIntPipe) id: number, @Body() dto: StandingDto) {
    const championshipId = dto.championshipId ?? (await this.ensureChampionship(dto.categoryId));
    return this.prisma.standing.update({ where: { id }, data: { ...dto, championshipId } });
  }

  private async ensureChampionship(categoryId: number) {
    const currentYear = new Date().getFullYear();
    const season = await this.prisma.season.upsert({
      where: { year_name: { year: currentYear, name: `Temporada ${currentYear}` } },
      update: { active: true },
      create: { year: currentYear, name: `Temporada ${currentYear}`, active: true },
    });

    const existing = await this.prisma.championship.findFirst({
      where: { seasonId: season.id, categoryId, active: true },
      select: { id: true },
    });
    if (existing) {
      return existing.id;
    }

    const category = await this.prisma.category.findUnique({ where: { id: categoryId }, select: { name: true } });
    const championship = await this.prisma.championship.create({
      data: {
        seasonId: season.id,
        categoryId,
        name: category?.name ? `${category.name} ${currentYear}` : `Campeonato ${currentYear}`,
        active: true,
      },
      select: { id: true },
    });

    return championship.id;
  }
}
