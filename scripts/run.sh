#!/usr/bin/env bash
set -euo pipefail

# Load env file: prefer envs/.env.development then .env
if [ -f "envs/.env.development" ]; then
  # shellcheck disable=SC1091
  set -o allexport
  source envs/.env.development
  set +o allexport
elif [ -f ".env" ]; then
  set -o allexport
  source .env
  set +o allexport
else
  echo "No env file found (envs/.env.development or .env). Using defaults."
fi

if [ -z "${API_BASE_URL-}" ]; then
  API_BASE_URL="http://10.0.2.2:3000"
fi

echo "Running flutter with API_BASE_URL=$API_BASE_URL"
flutter run --dart-define=API_BASE_URL="$API_BASE_URL" "$@"
