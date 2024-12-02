# Указываем базовый образ
FROM golang:1.22 AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем go.mod и go.sum для кэширования зависимостей
COPY go.mod go.sum ./

# Устанавливаем переменные окружения
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

# Загружаем зависимости
RUN go mod download

# Копируем код приложения
COPY . .

# Собираем приложение
RUN go build -o myapp .

# Создаем финальный образ
FROM alpine:latest

# Устанавливаем необходимые зависимости (если нужно)
RUN apk --no-cache add libc6-compat

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем скомпилированное приложение из образа builder
COPY --from=builder /app/myapp .

# Копируем файл базы данных
COPY tracker.db .

# Определяем команду для запуска приложения
CMD ["./myapp"]