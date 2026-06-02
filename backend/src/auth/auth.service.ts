import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserRole } from '@prisma/client';
import * as argon2 from 'argon2';
import { ImageService } from '../common/image.service';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto, RegisterDto } from './dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly images: ImageService,
  ) {}

  async register(dto: RegisterDto, photoFile: Express.Multer.File) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException('Este e-mail ja esta cadastrado.');
    }

    const photo = await this.images.prepareProfilePhoto(photoFile);
    const passwordHash = await argon2.hash(dto.password);

    const user = await this.prisma.user.create({
      data: {
        name: dto.name.trim(),
        email: dto.email.toLowerCase().trim(),
        phone: dto.phone.trim(),
        passwordHash,
        role: UserRole.PILOT,
        photo: {
          create: {
            mimeType: photo.mimeType,
            fileSize: photo.fileSize,
            width: photo.width,
            height: photo.height,
            imageData: photo.buffer,
          },
        },
      },
      select: this.publicUserSelect(),
    });

    return this.withToken(user);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase().trim() },
    });

    if (!user || !(await argon2.verify(user.passwordHash, dto.password))) {
      throw new UnauthorizedException('Credenciais invalidas.');
    }

    return this.withToken({
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
    });
  }

  private withToken(user: { id: number; name: string; email: string; phone: string; role: UserRole }) {
    return {
      user,
      accessToken: this.jwt.sign({ sub: user.id, role: user.role }),
    };
  }

  private publicUserSelect() {
    return {
      id: true,
      name: true,
      email: true,
      phone: true,
      role: true,
    };
  }
}
