FROM golang:1.12-alpine3.9 as builder
COPY . /go/src/github.com/concourse/s3-resource
ENV CGO_ENABLED 0
RUN go build -o /assets/in github.com/concourse/s3-resource/cmd/in
RUN go build -o /assets/out github.com/concourse/s3-resource/cmd/out
RUN go build -o /assets/check github.com/concourse/s3-resource/cmd/check
WORKDIR /go/src/github.com/concourse/s3-resource
RUN set -e; for pkg in $(go list ./...); do \
		go test -o "/tests/$(basename $pkg).test" -c $pkg; \
	done

FROM alpine:edge AS resource
RUN apk add --no-cache bash tzdata ca-certificates unzip zip gzip tar
COPY --from=builder assets/ /opt/resource/
RUN chmod +x /opt/resource/*


FROM resource
