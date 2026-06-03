# Ambiente local

Este projeto foi preparado para rodar localmente com:

- MySQL via Docker em `localhost:3306`.
- Backend NestJS em `http://localhost:3000/api`.
- Flutter apontando para a API via `API_BASE_URL`.

## Banco

```bash
docker compose up -d
```

Credenciais locais:

```text
DATABASE_URL="mysql://potatos:potatos123@localhost:3306/potatos_app"
```

## Backend

```bash
cd backend
npm install
copy .env.example .env
npx prisma generate
npx prisma migrate dev
npm run db:seed
npm run start:dev
```

## Mobile

Emulador Android:

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

iOS simulator:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

Dispositivo fisico na mesma rede:

```bash
flutter run --dart-define=API_BASE_URL=http://IP_DA_MAQUINA:3000/api
```

## Diagnostico

```bash
node --version
npm --version
flutter doctor
docker --version
```
