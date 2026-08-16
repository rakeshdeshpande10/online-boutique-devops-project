FROM golang:1.25-alpine AS builder
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o /go/bin/frontend .

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /src

COPY --from=builder /go/bin/frontend /src/server
COPY ./templates ./templates
COPY ./static ./static

EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/src/server"]

