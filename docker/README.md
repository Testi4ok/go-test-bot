# Docker

Ця папка містить Dockerfile файли для збірки контейнерних образів.

## Файли

- `Dockerfile` - Multi-platform Dockerfile для Linux (amd64, arm64)
- `Dockerfile.windows` - Dockerfile для Windows контейнерів

## Використання

Docker команди виконуються через Makefile з кореня проєкту:

```bash
# Збірка для Linux
make image-multi-linux

# Збірка для Windows
make image-windows

# Збірка для всіх платформ
make image-multi
```

## Контекст збірки

Контекст збірки Docker завжди є коренем проєкту (`.`), тому всі файли проєкту доступні під час збірки.

## Примітки

- Для multi-platform збірки використовується Docker buildx
- macOS контейнери не підтримуються (macOS не є контейнеризованою ОС)
- Windows контейнери працюють тільки на Windows host

