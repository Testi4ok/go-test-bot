# Go Test Bot

Telegram бот на Go з підтримкою мультиплатформенної збірки та тестування.

## Особливості

- ✅ Кросплатформенна збірка для Linux, macOS та Windows
- ✅ Підтримка архітектур: AMD64 та ARM64
- ✅ Multi-platform Docker образи для Linux та Windows
- ✅ Використання альтернативного container registry (ghcr.io)

## Вимоги

- Go 1.25.4 або новіша версія
- Docker з підтримкою buildx (для multi-platform збірки)
- Make (опціонально, для використання Makefile)

## Локальна збірка

> **Примітка**: Проєкт використовує безпечні вбудовані команди Go без batch файлів. Всі команди працюють нативно на Linux, macOS та Windows.

### Збірка для конкретної платформи

```bash
# Linux AMD64 (працює нативно через Go)
make linux-amd64

# Linux ARM64 (працює нативно через Go)
make linux-arm64

# macOS AMD64 (Intel)
make darwin-amd64

# macOS ARM64 (Apple Silicon)
make darwin-arm64

# Windows AMD64 (використовує PowerShell, без batch файлів)
make windows-amd64

# Windows ARM64 (використовує PowerShell, без batch файлів)
make windows-arm64
```

### Швидкий тест на Linux

```bash
# Збірка для Linux
make linux

# Перевірка зібраного бінарного файлу
./bin/go-test-bot-linux-amd64 version

# Або для ARM64
./bin/go-test-bot-linux-arm64 version
```

### Збірка для всіх платформ

```bash
make build-all
```

Це створить бінарні файли в директорії `bin/`:
- `bin/go-test-bot-linux-amd64`
- `bin/go-test-bot-linux-arm64`
- `bin/go-test-bot-darwin-amd64`
- `bin/go-test-bot-darwin-arm64`
- `bin/go-test-bot-windows-amd64.exe`
- `bin/go-test-bot-windows-arm64.exe`

### Швидкі команди

```bash
# Збірка тільки для Linux
make linux

# Збірка тільки для macOS
make darwin

# Збірка тільки для Windows
make windows

# Збірка для ARM (Linux ARM64)
make arm
```

## Docker збірка

### Налаштування Docker Buildx

Перед використанням multi-platform збірки переконайтеся, що buildx встановлений:

```bash
docker buildx version
```

Якщо потрібно, створіть новий builder:

```bash
docker buildx create --name multiplatform-builder --use
docker buildx inspect --bootstrap
```

### Збірка Docker образів

#### Linux (AMD64 та ARM64)

```bash
# Збірка та push для Linux платформ
make image-multi-linux
```

Це створить образи для:
- `linux/amd64`
- `linux/arm64`

#### Windows

```bash
# Збірка та push для Windows
make image-windows
```

#### Всі платформи

```bash
# Збірка та push для всіх підтримуваних платформ
make image-multi
```

### Локальне тестування Docker образів

Для тестування образів локально без push:

```bash
# Тестування Linux AMD64
make image-test-linux-amd64
docker run --rm ${REGISTRY}/${APP}:test-linux-amd64 version

# Тестування Linux ARM64 (потребує ARM64 машину або QEMU)
make image-test-linux-arm64
docker run --rm ${REGISTRY}/${APP}:test-linux-arm64 version

# Тестування Windows (потребує Windows host)
make image-test-windows
```

### Використання альтернативного Container Registry

За замовчуванням використовується GitHub Container Registry (ghcr.io). 

Щоб змінити registry, відредагуйте змінну `REGISTRY` в `Makefile`:

```makefile
REGISTRY=ghcr.io/your-username
# або
REGISTRY=quay.io/your-username
# або
REGISTRY=your-registry.com/your-org
```

### Автентифікація в Container Registry

#### GitHub Container Registry (ghcr.io)

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

#### Quay.io

```bash
docker login quay.io
```

## Тестування

```bash
# Запуск тестів
make test

# Форматування коду
make format

# Лінтування
make lint
```

## Примітки

### macOS в Docker

⚠️ **Важливо**: Docker не підтримує macOS контейнери, оскільки macOS не є контейнеризованою ОС. Для тестування на macOS використовуйте нативну збірку через Makefile:

```bash
make darwin-arm64  # для Apple Silicon
make darwin-amd64  # для Intel Mac
```

### ARM64 тестування

Для тестування ARM64 образів на x86_64 машині можна використовувати QEMU:

```bash
docker run --rm --platform linux/arm64 ${REGISTRY}/${APP}:latest version
```

Однак для нативного ARM64 тестування без емуляції рекомендовано використовувати ARM64 машину або CI/CD з ARM64 runners.

### Windows контейнери

Windows контейнери можуть працювати тільки на Windows host з підтримкою контейнерів або на Windows Server.

## Структура проєкту

```
.
├── cmd/                    # CLI команди
├── docker/                 # Docker файли
│   ├── Dockerfile          # Multi-platform Dockerfile для Linux
│   ├── Dockerfile.windows  # Dockerfile для Windows
│   └── README.md           # Документація Docker
├── docs/                   # Додаткова документація
│   ├── BUILD.md            # Детальні інструкції зі збірки
│   └── README.md           # Індекс документації
├── bin/                    # Зібрані бінарні файли (gitignored)
├── main.go                 # Точка входу
├── go.mod                  # Go модуль
├── go.sum                  # Go залежності
├── Makefile                # Команди збірки та автоматизації (без batch файлів)
├── .gitignore              # Git ignore правила
├── .gitattributes          # Git attributes для безпеки
├── SECURITY.md             # Політика безпеки
└── README.md               # Основна документація
```

## Додаткові ресурси

- [Docker Multi-platform builds](https://docs.docker.com/build/building/multi-platform/)
- [Go Cross Compilation](https://go.dev/doc/install/source#environment)
- [Docker Buildx](https://docs.docker.com/build/buildx/)

## Ліцензія

Див. файл LICENSE
