# stage 1 building the app
FROM golang:1.20.5-alpine3.18 AS builder

COPY db.go go.sum go.mod main.go /opt/code/

WORKDIR /opt/code

RUN go build -o internship

# stage 2 running the app
FROM alpine:latest

COPY --from=builder /opt/code /

ENTRYPOINT [ "./internship" ]
