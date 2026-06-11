# Potatos APP

Aplicativo mobile da liga Potatos RaceSim para pilotos e administradores.

O app permite cadastro de pilotos com foto obrigatoria, login, calendario por categoria, classificacao dos campeonatos, painel administrativo e recuperacao de senha.

## Funcionalidades

- Cadastro de pilotos com nome, e-mail, telefone, senha e foto obrigatoria.
- Login de pilotos e administradores.
- Recuperacao de senha com codigo temporario.
- Home do piloto com foto, nome, calendario, classificacao e link para o site oficial.
- Calendario por categoria.
- Classificacao por categoria com pontos, vitorias, poles, corridas e voltas mais rapidas.
- Painel administrativo para categorias, calendario, classificacao e notificacoes.
- Upload de fotos salvo no MySQL em tabela propria, usando `MEDIUMBLOB`.

## Stack

- Mobile: Flutter e Dart.
- Backend: NestJS e TypeScript.
- Banco de dados: MySQL.
- ORM: Prisma.
- Autenticacao: JWT.
- Hash de senhas e codigos: Argon2.

## Estrutura

```text
backend/   API NestJS, Prisma e regras de negocio
mobile/    Aplicativo Flutter
docs/      Documentacao de apoio do projeto
scripts/   Utilitarios locais de desenvolvimento
```

## Ambiente Local

Requisitos:

- Node.js
- Flutter
- MySQL, podendo ser via XAMPP
- Android SDK para build Android

Crie o arquivo `backend/.env` a partir de `backend/.env.example` e configure:

```env
DATABASE_URL="mysql://root:@localhost:3306/potatos_app"
JWT_SECRET="change-me"
JWT_EXPIRES_IN="1d"
ADMIN_EMAIL="admin@potatos.local"
ADMIN_PASSWORD="change-me-admin"
```

## Backend

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev
npm run start:dev
```

API local:

```text
http://localhost:3000/api
```

## Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

Para emulador Android, use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## Preview Web Local

Gere a build web:

```bash
cd mobile
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
```

Sirva a build:

```bash
node ../scripts/serve_flutter_web.js
```

Preview:

```text
http://127.0.0.1:8095
```

## Recuperacao de Senha

O fluxo atual gera um codigo temporario de 6 digitos com validade de 15 minutos.

Em ambiente local, o codigo aparece na tela para facilitar testes. Em producao, esse codigo deve ser enviado por e-mail, SMS ou WhatsApp e nao deve ser exibido diretamente no app.

## Admin Local

Usuario administrativo padrao para desenvolvimento:

```text
E-mail: admin@potatos.local
Senha: change-me-admin
```

## Validacao

Comandos usados para validar o projeto:

```bash
cd backend
npm run build

cd ../mobile
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
```

## Observacoes

- A funcionalidade de notificacoes esta preparada no painel administrativo, mas o envio push real esta pausado ate integracao com um provedor como Firebase Cloud Messaging.
- As fotos ficam no MySQL para evitar custo adicional com storage externo nesta fase.
- A arquitetura foi organizada para permitir evolucao futura sem reescrever o fluxo principal do app.
