FROM golang:1.16-alpine as builder

WORKDIR /app

ENV GO111MODULE auto
ENV GOFLAGS -mod=vendor

COPY vendor/ vendor/
COPY go.mod .
COPY go.sum .

run echo foo

COPY healthcheck.go .

RUN go build -o serve healthcheck.go

FROM alpine:latest

COPY --from=builder /app/serve .

CMD ["./serve"]
