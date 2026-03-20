FROM golang:1.25.8-alpine AS builder
WORKDIR /src

RUN apk add --no-cache git ca-certificates

# Copia tudo primeiro (para o tidy enxergar os imports reais)
COPY . .

# Tidy agora enxerga o código e resolve as dependências corretas
RUN go mod tidy

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/auth-service .

FROM alpine:3.20
WORKDIR /app
RUN adduser -D -u 10001 appuser
COPY --from=builder /out/auth-service /app/auth-service
USER appuser

EXPOSE 8001
ENV PORT=8001
CMD ["/app/auth-service"]
