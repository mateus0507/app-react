# Define a imagem base usando Node.js versão 20 com Alpine Linux
# Essa imagem será reutilizada nos estágios de dependências e build
FROM node:20-alpine AS base

# Define o diretório de trabalho dentro do container como /app
WORKDIR /app


# Inicia o estágio "deps" (dependências), baseado na imagem base
# Esse estágio instala apenas as dependências do projeto
FROM base AS deps

# Copia os arquivos de dependências para dentro do container
# package.json → lista de dependências
# package-lock.json* → garante versões fixas (se existir)
COPY package.json package-lock.json* ./

# Instala as dependências do projeto
RUN npm install


# Inicia o estágio "builder"
# Esse estágio será responsável por gerar o build da aplicação React
FROM base AS builder

# Copia as dependências já instaladas do estágio anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia todo o código da aplicação para dentro do container
COPY . .

# Executa o build da aplicação
# Em projetos React com Vite, isso gera a pasta /app/dist
RUN npm run build


# Inicia o estágio final chamado "runner"
# Aqui usamos Nginx para servir os arquivos estáticos em produção
FROM nginx:alpine AS runner

# Copia os arquivos gerados no build para a pasta padrão do Nginx
# Essa pasta é servida automaticamente pelo Nginx
COPY --from=builder /app/dist /usr/share/nginx/html


# Cria uma configuração customizada do Nginx diretamente no container
# Isso é necessário porque, por padrão, o Nginx usa a porta 80
# Aqui estamos alterando para usar a porta 3000
RUN printf 'server {\n\
    listen 3000;\n\
    server_name localhost;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf


# Informa que o container utilizará a porta 3000
# Isso não abre a porta, apenas documenta para o Docker
EXPOSE 3000


# Comando padrão para iniciar o Nginx em primeiro plano
# "daemon off;" mantém o processo ativo para o container não encerrar
CMD ["nginx", "-g", "daemon off;"]