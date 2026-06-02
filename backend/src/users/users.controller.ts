import { Controller, Get, NotFoundException, Param, ParseIntPipe, Res } from '@nestjs/common';
import { Response } from 'express';
import { PrismaService } from '../prisma/prisma.service';

@Controller('users')
export class UsersController {
  constructor(private readonly prisma: PrismaService) {}

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
