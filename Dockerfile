FROM golang:1.20.5-alpine3.18

COPY . /opt/code

WORKDIR /opt/code

RUN go build -o internship

ENTRYPOINT [ "./internship" ]
