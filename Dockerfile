FROM rust:latest as builder

WORKDIR /app

COPY . .

RUN RUSTFLAGS="-C target-cpu=native" cargo build --release -q

FROM debian:latest

WORKDIR /app

COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
COPY --from=builder /app/target/release/bilibili-webhook /usr/local/bin/
COPY log.yml .

RUN apt update -y && \
    apt install python3 python3-dev python3-pip ffmpeg  -y && \
    pip3 install --no-cache-dir yutto --pre

RUN addgroup -g 1000 pi && adduser -D -s /bin/sh -u 1000 -G pi pi && chown -R pi:pi .

USER pi

VOLUME ["/app/config", "/app/downloads"]

CMD bilibili-webhook
