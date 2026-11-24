FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git make gcc musl-dev
RUN git clone https://github.com/kgretzky/evilginx2.git
WORKDIR /go/evilginx2
RUN make

FROM alpine:latest
# Added tmux here:
RUN apk add --no-cache ca-certificates socat bash util-linux tmux
WORKDIR /app
COPY --from=builder /go/evilginx2/build/evilginx /app/evilginx
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
COPY phishlets/ /app/phishlets/

EXPOSE 80 443

USER root

CMD ["/app/start.sh"]
