FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git make gcc musl-dev
RUN git clone https://github.com/kgretzky/evilginx2.git
WORKDIR /go/evilginx2
RUN make

FROM alpine:latest
RUN apk add --no-cache ca-certificates socat bash util-linux
WORKDIR /app
COPY --from=builder /go/evilginx2/build/evilginx /app/evilginx

# Create the phishlets directory
RUN mkdir /app/phishlets

EXPOSE 80 443

# Start the port forwarder, run Evilginx in a pseudo-terminal, and keep the container alive
CMD ["/bin/sh", "-c", "socat TCP-LISTEN:${PORT:-8080},fork TCP:127.0.0.1:80 & script -q -c '/app/evilginx' /dev/null & tail -f /dev/null"]
