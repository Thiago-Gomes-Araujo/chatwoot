#!/bin/sh

set -x

# Remove arquivos antigos
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

until pg_isready -h "${POSTGRES_HOST:-postgres}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USERNAME:-postgres}"; do
  echo "⏳ Aguardando Postgres..."
  sleep 2
done

echo "✅ Database ready to accept connections."

# Garante que gems estão instaladas
bundle install

# Espera até que bundle esteja válido
until bundle check; do
  sleep 2
done

# Cria banco e roda migrations
echo "Running database setup..."
bundle exec rails db:prepare

# Inicia o processo principal (Rails server ou Sidekiq)
exec "$@"
