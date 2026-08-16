FROM golang:1.25.8-alpine AS builder
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o /go/bin/productcatalogservice .

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /src

COPY --from=builder /go/bin/productcatalogservice /src/server
COPY products.json ./products.json

EXPOSE 3550
USER nonroot:nonroot
ENTRYPOINT ["/src/server"]