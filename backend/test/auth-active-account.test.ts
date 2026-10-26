import assert from 'node:assert/strict';
import { test } from 'node:test';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { UnauthorizedException } from '@nestjs/common';
import { AuthService } from '../src/auth/auth.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { ImageService } from '../src/common/image.service';

const password = 'test-pilot-password';

async function serviceFor(active: boolean) {
  const passwordHash = await argon2.hash(password);
  const prisma = {
    user: {
      findUnique: async () => ({
        id: 10, name: 'Pilot One', email: 'pilot@example.com', phone: '+5511999999999',
        passwordHash, role: 'PILOT', active,
      }),
    },
  } as unknown as PrismaService;
  return new AuthService(prisma, new JwtService({ secret: 'auth-test-secret' }), {} as ImageService);
}

test('rejects valid credentials for an inactive Potatos APP account', async () => {
  const service = await serviceFor(false);
  await assert.rejects(service.login({ email: 'pilot@example.com', password }), UnauthorizedException);
});

test('returns active status for an authenticated Potatos APP account', async () => {
  const service = await serviceFor(true);
  const result = await service.login({ email: 'pilot@example.com', password });
  assert.equal(result.user.active, true);
  assert.equal(typeof result.accessToken, 'string');
});
