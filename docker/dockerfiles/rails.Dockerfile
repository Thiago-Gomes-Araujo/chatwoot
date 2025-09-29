# =========================
# Stage Base Ruby (produção) - Debian Slim
# =========================
FROM ruby:3.4.4-slim AS base

# Dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    tzdata \
    imagemagick \
    git \
    curl \
    gnupg \
    libvips-dev \
    libxml2-dev \
    libxslt1-dev \
    g++ \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala Node 23.x + pnpm 10 (necessário pro Chatwoot 4.6+)
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g pnpm@10

# Copia apenas Gemfile e Gemfile.lock para cache
COPY Gemfile Gemfile.lock ./

# Instala Bundler compatível
RUN gem install bundler -v 2.5.16

# Instala gems sem development/test
RUN bundle config set --local without 'development test' \
 && bundle install -j 4 --retry 3

# Copia a aplicação
COPY . .

# Variáveis de produção
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=placeholder_secret
ENV RAILS_SERVE_STATIC_FILES=true

# Instala dependências JS via pnpm
RUN pnpm install

# Pré-compila assets Rails + Vite
RUN bundle exec rails assets:precompile

# Limpa caches para reduzir tamanho da imagem
#RUN rm -rf tmp/cache node_modules .bundle

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
