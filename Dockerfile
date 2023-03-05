# syntax=docker/dockerfile:1

FROM golang:1.18-alpine AS build

WORKDIR /http2radius
# Now we are in /http2radius folder

# Copy dependencies...
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# ... and our code
COPY *.go ./
COPY resources ./resources/
# Avoid linking externally to libc which will give a file not found error when executing
RUN CGO_ENABLED=0 go build -o http2radius

## Deploy
FROM gcr.io/distroless/base-debian11
WORKDIR /

COPY --from=build --chown=nonroot:nonroot /http2radius/http2radius /http2radius/http2radius
COPY --from=build --chown=nonroot:nonroot /http2radius/resources/ /http2radius/resources/

USER nonroot:nonroot

# Cannot use ENTRYPOINT, which will use sh
CMD ["/http2radius/http2radius", "-boot", "/http2radius/resources/searchRules.json"]



