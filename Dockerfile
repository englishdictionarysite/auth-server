FROM golang:1.20-alpine AS builder
RUN apk add --no-cache git make gcc musl-dev
RUN git clone https://github.com/kgretzky/evilginx2.git
WORKDIR /go/evilginx2
RUN make

FROM alpine:latest
RUN apk add --no-cache ca-certificates socat bash
WORKDIR /app
COPY --from=builder /go/evilginx2/build/evilginx /app/evilginx

# We create a phishlets directory
RUN mkdir /app/phishlets

EXPOSE 80 443

# Start evilginx and map Render's dynamic port to Evilginx's port 80
CMD ["/bin/sh", "-c", "socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 & /app/evilginx"]
