FROM node:14.16-alpine

WORKDIR /usr/src/app

COPY . .

RUN apk add --no-cache git make gcc g++ python && \
  npm install --non-interactive --frozen-lockfile && \
  apk del make gcc g++ python

RUN npm run compile

RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ./docker-entrypoint.sh