# Multi-platform Dockerfile для Linux (amd64, arm64)
# Використовуємо Docker buildx для кросплатформенної збірки
# Примітка: macOS не підтримується в Docker контейнерах, використовуйте нативну збірку через Makefile
# Для Windows використовуйте Dockerfile.windows

# Stage 1: Builder
FROM --platform=$BUILDPLATFORM golang:1.25.4 AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=dev

# Безпека: встановлюємо робочу директорію
WORKDIR /go/src/app

# Безпека: копіюємо тільки необхідні файли залежностей спочатку для кращого кешування
COPY go.mod go.sum ./

# Безпека: завантажуємо залежності без кешування для перевірки цілісності
RUN go mod download && go mod verify

# Безпека: копіюємо тільки необхідні файли коду (не включаємо .git, bin/, тощо)
COPY *.go ./
COPY cmd/ ./cmd/

# Безпека: збираємо бінарний файл з вимкненим CGO для мінімізації атак
# Використовуємо статичну збірку без залежностей від системних бібліотек
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    go build -v \
    -trimpath \
    -ldflags="-s -w -X=github.com/Testi4ok/go-test-bot/cmd.appVersion=${VERSION}" \
    -o go-test-bot \
    .

# Stage 2: Final image (мінімальний образ для безпеки)
FROM scratch

# Безпека: копіюємо тільки бінарний файл та сертифікати
COPY --from=builder /go/src/app/go-test-bot /go-test-bot
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Безпека: використовуємо явний ENTRYPOINT без shell для запобігання injection
ENTRYPOINT ["/go-test-bot"]
