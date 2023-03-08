FROM golang:latest AS builder

WORKDIR /go/src/app

ENV CGO_ENABLED=1
# ENV GO111MODULE=on
ENV GOOS=linux
ENV GOARCH=amd64

COPY go.mod ./
COPY go.sum ./
COPY ./vendor/github.com/bwmarrin/discordgo/go.mod ./vendor/github.com/bwmarrin/discordgo/go.mod
COPY ./vendor/github.com/bwmarrin/discordgo/go.sum ./vendor/github.com/bwmarrin/discordgo/go.sum

RUN go mod download

COPY . .

RUN mkdir -p ./data && \
  cp ./docs/build.sh ./

RUN ./build.sh

FROM alpine:latest

COPY --from=builder --chmod=0755 /go/src/app/autodelete /

ENV HOME=/

ENV CLIENT_ID $CLIENT_ID
ENV CLIENT_SECRET $CLIENT_SECRET
ENV BOT_TOKEN $BOT_TOKEN
ENV ADMIN_USER $ADMIN_USER
ENV SHARDS $SHARDS
ENV ERROR_LOG $ERROR_LOG
ENV HTTP_LISTEN $HTTP_LISTEN
ENV HTTP_PUBLIC $HTTP_PUBLIC
ENV STATUS_MESSAGE $STATUS_MESSAGE
ENV DONOR_GUILD $DONOR_GUILD
ENV DONOR_ROLE_IDS $DONOR_ROLE_IDS
ENV BACKLOG_LIMIT $BACKLOG_LIMIT
ENV DONOR_BACKLOG_LIMIT $DONOR_BACKLOG_LIMIT

ENTRYPOINT ["/autodelete", "--nohttp"]
