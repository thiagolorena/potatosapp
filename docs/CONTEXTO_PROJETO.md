# Contexto do Projeto - Potatos Racing App

Data: 2026-06-02

## Objetivo

Criar uma aplicacao mobile Android/iOS para a liga Potatos, com cadastro de pilotos, foto obrigatoria, login, calendario de corridas por categoria, classificacao de campeonatos por categoria e perfil administrativo para CRUD de categorias, calendario e classificacao.

## Decisoes tecnicas

- Frontend mobile: Flutter + Dart.
- Backend: NestJS + TypeScript.
- Banco remoto: MySQL.
- ORM: Prisma.
- Autenticacao: JWT.
- Fotos: armazenadas no MySQL em `user_photos.image_data` como `MEDIUMBLOB`.
- Processamento de fotos: `sharp`, convertendo a imagem para JPEG comprimido e dimensao padronizada antes de persistir.

## Observacao sobre identidade visual

O site `https://potatos.com.br/` foi usado como referencia solicitada, mas durante a execucao desta etapa ele nao respondeu via browser/search e retornou erro de conexao no `Invoke-WebRequest`. Por isso, a identidade visual foi centralizada em `mobile/lib/core/theme/potatos_theme.dart`, com tokens faceis de ajustar quando as cores oficiais forem capturadas.

Tema inicial:

- Grafite/asfalto para fundo.
- Amarelo Potatos como cor principal.
- Vermelho corrida como acento.
- Branco bandeira para textos.
- Linhas cinza para divisorias e cards.

## Funcionalidades iniciadas

Backend:

- Cadastro de piloto com foto obrigatoria.
- Login com JWT.
- Compressao de foto e persistencia no MySQL.
- Endpoint para retornar foto do piloto.
- CRUD inicial de categorias.
- CRUD inicial de calendario.
- CRUD inicial de classificacao.
- Guardas JWT/ADMIN para rotas administrativas de escrita.
- Seed Prisma para criar/atualizar o primeiro usuario ADMIN a partir do `.env`.
- Schema Prisma com usuarios, fotos, temporadas, categorias, campeonatos, eventos e classificacao.

Mobile:

- Login.
- Cadastro com foto obrigatoria.
- Home com opcoes Calendario e Classificacao.
- Selecao de categoria.
- Listagem de calendario por categoria.
- Listagem de classificacao por categoria.
- Tela inicial de administrativo.
- Tema visual centralizado.

## Proximas etapas recomendadas

1. Instalar Node/NPM e Flutter no ambiente de desenvolvimento.
2. Rodar `npm install` em `backend/`.
3. Configurar `.env` com `DATABASE_URL` do MySQL remoto.
4. Rodar `npx prisma generate` e `npx prisma migrate dev`.
5. Rodar `npm run db:seed` para criar o primeiro ADMIN.
6. Rodar `flutter pub get` em `mobile/`.
7. Criar formularios completos no app para admin cadastrar categorias, eventos e classificacao.
8. Adicionar refresh token.
9. Adicionar testes unitarios e e2e.
10. Ajustar paleta com as cores oficiais do site Potatos quando acessivel.

## Referencias de produto

- PaddockHub: plataforma de liga com perfis, calendario, classificacao e gestao.
- GridChief: foco em calendario, standings e eliminacao de planilhas.
- TraceLap: identidade de piloto, campeonato e administracao de liga.
- Resultrics: resultados e classificacao por classe/categoria.
- OneRacing: calendario e classificacao como experiencia principal do usuario.
