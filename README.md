# Potatos Racing App

Aplicacao mobile para Android e iOS da liga Potatos, com cadastro de pilotos, foto obrigatoria, calendario por categoria, classificacao por campeonato e painel administrativo.

## Estrutura

- `mobile/`: app Flutter.
- `backend/`: API NestJS com MySQL remoto via Prisma.
- `docs/`: contexto, arquitetura e decisoes do projeto.

## Stack

- Mobile: Flutter + Dart.
- Backend: NestJS + TypeScript.
- Banco: MySQL remoto.
- ORM: Prisma.
- Fotos: armazenadas no MySQL em tabela separada usando `MEDIUMBLOB`, apos compressao no backend.

## Primeiros passos

Ambiente local completo em [docs/AMBIENTE_LOCAL.md](docs/AMBIENTE_LOCAL.md).

Backend:

```bash
cd backend
npm install
cp .env.example .env
npx prisma generate
npx prisma migrate dev
npm run start:dev
```

Mobile:

```bash
cd mobile
flutter pub get
flutter run
```

> Observacao: nesta maquina, Flutter/Node/NPM nao estavam disponiveis no PATH durante a criacao do scaffold, entao os comandos acima ainda precisam ser executados em um ambiente com as ferramentas instaladas.
