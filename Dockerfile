FROM golang:1.20-alpine3.17 as build
WORKDIR /opt
COPY . .
RUN apk add git
RUN git clone https://github.com/opensvc/om3 && cd om3 && git checkout -d v3.0.0-alpha2
WORKDIR /opt/om3
RUN GOOS=linux GOARCH=amd64 go build -tags nodrv -o om

FROM alpine:3.17 as final
COPY --from=build /opt/om3/om /usr/bin/
COPY ./docker-entrypoint.sh /
ENV ADDR=${ADDR:-0.0.0.0}
ENV PORT=${PORT:-1214}
EXPOSE ${PORT}/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["relay"]

