# Інструкції зі збірки та тестування

## Швидкий старт

### 1. Локальна збірка для різних платформ

```bash
# Збірка для Linux
make linux

# Збірка для macOS
make darwin

# Збірка для Windows
make windows

# Збірка для всіх платформ
make build-all
```

### 2. Docker multi-platform збірка

#### Налаштування (один раз)

```bash
# Створення buildx builder
docker buildx create --name multiplatform-builder --use
docker buildx inspect --bootstrap
```

#### Збірка та публікація образів

```bash
# Linux (amd64 + arm64)
make image-multi-linux

# Windows
make image-windows

# Всі платформи
make image-multi
```

### 3. Зміна Container Registry

Відредагуйте `Makefile`, змініть змінну `REGISTRY`:

```makefile
REGISTRY=ghcr.io/your-username
# або
REGISTRY=quay.io/your-username
# або
REGISTRY=testi4ok  # ваш поточний registry
```

### 4. Автентифікація

#### GitHub Container Registry

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

#### Quay.io

```bash
docker login quay.io
```

## Приклади використання

### Тестування локальної збірки

```bash
# Linux AMD64
make linux-amd64
./bin/go-test-bot-linux-amd64 version

# macOS ARM64 (Apple Silicon)
make darwin-arm64
./bin/go-test-bot-darwin-arm64 version

# Windows AMD64
make windows-amd64
# На Windows: bin\go-test-bot-windows-amd64.exe version
```

### Тестування Docker образів

```bash
# Linux AMD64
make image-test-linux-amd64
docker run --rm ghcr.io/your-username/go-test-bot:test-linux-amd64 version

# Linux ARM64 (з QEMU емуляцією на x86_64)
make image-test-linux-arm64
docker run --rm --platform linux/arm64 ghcr.io/your-username/go-test-bot:test-linux-arm64 version
```

## Важливі примітки

1. **macOS контейнери**: Docker не підтримує macOS контейнери. Використовуйте нативну збірку через `make darwin-arm64` або `make darwin-amd64`.

2. **ARM64 без емуляції**: Для нативного ARM64 тестування без QEMU використовуйте ARM64 машину або CI/CD з ARM64 runners.

3. **Windows контейнери**: Працюють тільки на Windows host з підтримкою контейнерів.

## Troubleshooting

### Помилка: "buildx not found"

Встановіть Docker buildx:
- Docker Desktop: вже включено
- Linux: `docker buildx install`

### Помилка: "failed to solve: failed to compute cache key"

Переконайтеся, що файли `go.mod` та `go.sum` присутні в проєкті.

### Помилка автентифікації в registry

Перевірте, що ви увійшли в registry:
```bash
docker login <your-registry>
```

