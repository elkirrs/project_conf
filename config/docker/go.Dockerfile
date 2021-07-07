FROM golang:alpine AS golang
ENV NAME "golang"
WORKDIR /var/${NAME}
COPY ./go/go.mod .
COPY ./go/go.sum .
#RUN go mod download

FROM golang AS build
ENV NAME "golang"
WORKDIR /var/${NAME}
COPY ./go .
RUN GO111MODULE=auto
#RUN go build -o var/golang -ldflags '-v -w -s' ./cmd/golang
RUN ["sh",  "-c", "go build -o var/golang -ldflags '-v -w -s' ./cmd/golang"]

FROM alpine
ENV NAME "golang"
WORKDIR /var/${NAME}
COPY --from=build /var/${NAME} ./${NAME}
CMD ./${NAME}