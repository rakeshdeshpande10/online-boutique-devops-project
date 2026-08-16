FROM golang:1.25.0-alpine AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN  go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o checkoutservice .

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app

COPY --from=build /app/checkoutservice .

EXPOSE 5050
USER nonroot:nonroot
ENTRYPOINT ["/app/checkoutservice"]