import { PrismaClient, UserRole } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  const email = process.env.ADMIN_EMAIL ?? 'admin@potatos.local';
  const password = process.env.ADMIN_PASSWORD ?? 'change-me-admin';

  await prisma.user.upsert({
    where: { email },
    update: {
      role: UserRole.ADMIN,
      active: true,
    },
    create: {
      name: process.env.ADMIN_NAME ?? 'Administrador Potatos',
      email,
      phone: process.env.ADMIN_PHONE ?? '00000000000',
      passwordHash: await argon2.hash(password),
      role: UserRole.ADMIN,
    },
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
