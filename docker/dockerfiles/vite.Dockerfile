# Base Node (somente para dev ou build local, não produção real)
FROM node:23-alpine

# Dependências
RUN apk update && apk add --no-cache git bash curl

WORKDIR /app

# Copia package.json e lock
COPY package.json pnpm-lock.yaml ./

# Instala pnpm e dependências
RUN npm install -g pnpm@10.2.0
RUN pnpm install --frozen-lockfile

# Copia aplicação
COPY . .

# Em produção, NÃO precisa rodar `pnpm build`
# Apenas deixamos dev server disponível se precisar (não recomendado)
EXPOSE 3036

# Comando padrão (para dev)
CMD ["pnpm", "dev"]
