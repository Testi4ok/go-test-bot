APP=$(shell basename $(shell git remote get-url origin) .git)
# Використовуємо GitHub Container Registry як альтернативу DockerHub
# Можна змінити на testi4ok або інший registry
REGISTRY=ghcr.io/$(shell git config user.name 2>/dev/null || echo testi4ok)
VERSION=$(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64

# Безпека: валідація версії (запобігає injection атакам)
# Дозволяє тільки безпечні символи: літери, цифри, точки, дефіси, підкреслення
SAFE_VERSION=$(shell echo '$(VERSION)' | sed 's/[^a-zA-Z0-9._-]//g')

# Бінарні файли для різних платформ
BINARY_LINUX_AMD64=bin/go-test-bot-linux-amd64
BINARY_LINUX_ARM64=bin/go-test-bot-linux-arm64
BINARY_DARWIN_AMD64=bin/go-test-bot-darwin-amd64
BINARY_DARWIN_ARM64=bin/go-test-bot-darwin-arm64
BINARY_WINDOWS_AMD64=bin/go-test-bot-windows-amd64.exe
BINARY_WINDOWS_ARM64=bin/go-test-bot-windows-arm64.exe

.PHONY: all format lint test get clean build-all linux darwin windows arm

all: format get test build-all

format:
	gofmt -s -w .

lint:
	golint

test:
	go test -v

get:
	go get

# Збірка для всіх платформ
build-all: linux darwin windows

# Детекція ОС для крос-платформенної сумісності
ifeq ($(OS),Windows_NT)
    MKDIR_CMD = if not exist bin mkdir bin
    RM_CMD = del /Q
    RMDIR_CMD = rmdir /S /Q
    # Безпечне встановлення змінних середовища через PowerShell
    SET_ENV = powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='$(1)'; $$env:GOARCH='$(2)';"
else
    MKDIR_CMD = mkdir -p bin
    RM_CMD = rm -f
    RMDIR_CMD = rm -rf
    SET_ENV = CGO_ENABLED=0 GOOS=$(1) GOARCH=$(2)
endif

# Валідація версії для безпеки (запобігає injection атакам)
VALIDATE_VERSION = $(shell echo '$(VERSION)' | grep -E '^[a-zA-Z0-9._-]+$$' || echo 'invalid')

# Linux targets
linux: linux-amd64 linux-arm64

linux-amd64:
	@echo "Building for Linux AMD64..."
	@$(MKDIR_CMD)
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='linux'; $$env:GOARCH='amd64'; go build -v -o $(BINARY_LINUX_AMD64) -ldflags='-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)' ."
else
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -o $(BINARY_LINUX_AMD64) -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

linux-arm64:
	@echo "Building for Linux ARM64..."
	@$(MKDIR_CMD)
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='linux'; $$env:GOARCH='arm64'; go build -v -o $(BINARY_LINUX_ARM64) -ldflags='-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)' ."
else
	@CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -v -o $(BINARY_LINUX_ARM64) -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

# macOS (Darwin) targets
darwin: darwin-amd64 darwin-arm64

darwin-amd64:
	@echo "Building for macOS AMD64..."
	@$(MKDIR_CMD)
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='darwin'; $$env:GOARCH='amd64'; go build -v -o $(BINARY_DARWIN_AMD64) -ldflags='-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)' ."
else
	@CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -v -o $(BINARY_DARWIN_AMD64) -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

darwin-arm64:
	@echo "Building for macOS ARM64 (Apple Silicon)..."
	@$(MKDIR_CMD)
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='darwin'; $$env:GOARCH='arm64'; go build -v -o $(BINARY_DARWIN_ARM64) -ldflags='-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)' ."
else
	@CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -v -o $(BINARY_DARWIN_ARM64) -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

# Windows targets
windows: windows-amd64 windows-arm64

windows-amd64:
	@echo "Building for Windows AMD64..."
	@$(MKDIR_CMD)
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='windows'; $$env:GOARCH='amd64'; go build -v -o $(BINARY_WINDOWS_AMD64) -ldflags='-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)' ."
else
	@CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -v -o $(BINARY_WINDOWS_AMD64) -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

windows-arm64:
	@echo "Building for Windows ARM64..."
	@$(MKDIR_CMD)
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -Command "$$env:CGO_ENABLED='0'; $$env:GOOS='windows'; $$env:GOARCH='arm64'; go build -v -o $(BINARY_WINDOWS_ARM64) -ldflags='-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)' ."
else
	@CGO_ENABLED=0 GOOS=windows GOARCH=arm64 go build -v -o $(BINARY_WINDOWS_ARM64) -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

# ARM targets (alias для Linux ARM64)
arm: linux-arm64

# Стандартна збірка (для зворотної сумісності)
build: format get
ifeq ($(OS),Windows_NT)
	@cmd /c "set CGO_ENABLED=0 && set GOOS=$(TARGETOS) && set GOARCH=$(TARGETARCH) && go build -v -o go-test-bot.exe -ldflags=-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION) ."
else
	@CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o go-test-bot -ldflags="-X=github.com/Testi4ok/go-test-bot/cmd.appVersion=$(VERSION)" .
endif

# Docker команди
image:
	docker build -f docker/Dockerfile . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

# Multi-platform Docker build з buildx для Linux
image-multi-linux:
	@echo "Building multi-platform Docker images for Linux..."
	docker buildx create --use --name multiplatform-builder 2>/dev/null || true
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t ${REGISTRY}/${APP}:${VERSION} \
		-t ${REGISTRY}/${APP}:latest \
		--push \
		-f docker/Dockerfile \
		.

# Windows Docker build
image-windows:
	@echo "Building Windows Docker image..."
	docker buildx create --use --name multiplatform-builder 2>/dev/null || true
	docker buildx build --platform windows/amd64 \
		-t ${REGISTRY}/${APP}:${VERSION}-windows \
		--push \
		-f docker/Dockerfile.windows \
		.

# Multi-platform Docker build для всіх підтримуваних платформ
image-multi: image-multi-linux image-windows

# Тестування локально для конкретної платформи (без push)
image-test-linux-amd64:
	docker buildx build --platform linux/amd64 \
		-t ${REGISTRY}/${APP}:test-linux-amd64 \
		--load \
		-f docker/Dockerfile \
		.

image-test-linux-arm64:
	docker buildx build --platform linux/arm64 \
		-t ${REGISTRY}/${APP}:test-linux-arm64 \
		--load \
		-f docker/Dockerfile \
		.

image-test-windows:
	docker buildx build --platform windows/amd64 \
		-t ${REGISTRY}/${APP}:test-windows \
		--load \
		-f docker/Dockerfile.windows \
		.

# Push для конкретної платформи
push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

# Push для всіх платформ
push-multi: image-multi

clean:
ifeq ($(OS),Windows_NT)
	@if exist go-test-bot del /Q go-test-bot 2>nul
	@if exist bin\go-test-bot-*.exe del /Q bin\go-test-bot-*.exe 2>nul
	@if exist bin\go-test-bot-* del /Q bin\go-test-bot-* 2>nul
	@if exist bin rmdir /S /Q bin 2>nul
else
	@rm -rf go-test-bot bin/
endif