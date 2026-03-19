
# Define a imagem base usando Node.js versão 20 com Alpine Linux
# Essa imagem será usada como base para os estágios de instalação e build
FROM node:20-alpine AS base

# Define o diretório de trabalho dentro do container como /app
# Todos os comandos seguintes serão executados dentro dessa pasta
WORKDIR /app

ENV PORT=3000
# Inicia um novo estágio chamado "deps", baseado na imagem "base"
# Esse estágio será responsável apenas por instalar as dependências do projeto
FROM base AS deps

# Copia os arquivos de definição de dependências para dentro do container
# package.json contém as dependências e scripts do projeto
# package-lock.json* ajuda a garantir versões consistentes
# O * permite que o build continue mesmo se o package-lock.json não existir
COPY package.json package-lock.json* ./

# Instala as dependências do projeto
# Isso cria a pasta node_modules dentro do container
RUN npm install


# Inicia um novo estágio chamado "builder", também baseado em "base"
# Esse estágio será responsável por gerar o build da aplicação React
FROM base AS builder

# Copia a pasta node_modules do estágio "deps"
# Isso evita reinstalar as dependências novamente
COPY --from=deps /app/node_modules ./node_modules

# Copia todos os arquivos do projeto para dentro do container
# Aqui entram src, public, vite.config.js, etc
COPY . .

# Executa o comando de build da aplicação
# Em projetos React com Vite, isso normalmente gera a pasta /app/dist
RUN npm run build


# Inicia o estágio final chamado "runner"
# Nesse caso, usamos Nginx para servir os arquivos estáticos do React em produção
FROM nginx:alpine AS runner

# Copia os arquivos gerados no build do React para a pasta padrão do Nginx
# O Nginx irá servir o conteúdo da pasta /usr/share/nginx/html
COPY --from=builder /app/dist /usr/share/nginx/html

# Expõe a porta 80, que é a porta padrão usada pelo Nginx dentro do container
# Isso documenta que a aplicação responde internamente nessa porta
EXPOSE 3000

# Comando padrão para iniciar o Nginx em primeiro plano
# "daemon off;" mantém o processo ativo para o container não encerrar
CMD ["nginx", "-g", "daemon off;"]