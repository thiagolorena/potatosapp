import { BadRequestException, Injectable } from '@nestjs/common';
import sharp = require('sharp');

export type PreparedPhoto = {
  buffer: Buffer;
  mimeType: string;
  fileSize: number;
  width: number;
  height: number;
};

@Injectable()
export class ImageService {
  async prepareProfilePhoto(file?: Express.Multer.File): Promise<PreparedPhoto> {
    if (!file) {
      throw new BadRequestException('A foto do piloto e obrigatoria.');
    }

    const maxBytes = Number(process.env.MAX_PHOTO_MB ?? 5) * 1024 * 1024;
    if (file.size > maxBytes) {
      throw new BadRequestException('A foto ultrapassa o tamanho maximo permitido.');
    }

    const size = Number(process.env.PHOTO_SIZE ?? 640);
    const quality = Number(process.env.PHOTO_QUALITY ?? 78);

    const image = sharp(file.buffer)
      .rotate()
      .resize(size, size, { fit: 'cover', position: 'attention' })
      .jpeg({ quality, mozjpeg: true });

    const buffer = await image.toBuffer();
    const metadata = await sharp(buffer).metadata();

    return {
      buffer,
      mimeType: 'image/jpeg',
      fileSize: buffer.byteLength,
      width: metadata.width ?? size,
      height: metadata.height ?? size,
    };
  }
}
