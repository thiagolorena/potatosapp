import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserRole } from '@prisma/client';
import * as argon2 from 'argon2';
import { ImageService } from '../common/image.service';
import { PrismaService } from '../prisma/prisma.service';
import { ForgotPasswordDto, LoginDto, RegisterDto, ResetPasswordDto } from './dto';

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

  async forgotPassword(dto: ForgotPasswordDto) {
    const email = dto.email.toLowerCase().trim();
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user) {
      return {
        message:
          'Se o e-mail estiver cadastrado, enviaremos as instruções de recuperação.',
      };
    }

    await this.prisma.passwordResetToken.updateMany({
      where: { userId: user.id, usedAt: null },
      data: { usedAt: new Date() },
    });

    const code = this.createResetCode();
    const tokenHash = await argon2.hash(code);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await this.prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt,
      },
    });

    return {
      message: 'Código de recuperação gerado.',
      resetCode: code,
      expiresInMinutes: 15,
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const email = dto.email.toLowerCase().trim();
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user) {
      throw new BadRequestException('Código de recuperação inválido.');
    }

    const resetTokens = await this.prisma.passwordResetToken.findMany({
      where: {
        userId: user.id,
        usedAt: null,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    const token = await this.findMatchingResetToken(resetTokens, dto.code);
    if (!token) {
      throw new BadRequestException('Código de recuperação inválido ou expirado.');
    }

    const passwordHash = await argon2.hash(dto.password);

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: user.id },
        data: { passwordHash },
      }),
      this.prisma.passwordResetToken.update({
        where: { id: token.id },
        data: { usedAt: new Date() },
      }),
    ]);

    return { message: 'Senha atualizada com sucesso.' };
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

  private createResetCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  private async findMatchingResetToken(
    resetTokens: { id: number; tokenHash: string }[],
    code: string,
  ) {
    const normalizedCode = code.trim();
    for (const token of resetTokens) {
      if (await argon2.verify(token.tokenHash, normalizedCode)) {
        return token;
      }
    }
    return null;
  }
}
