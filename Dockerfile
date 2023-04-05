FROM node:18.15.0-alpine as builder

WORKDIR /src

COPY ./package.json .
COPY ./package-lock.json .

RUN npm i -g @nestjs/cli@9.0.0

RUN npm install --omit=dev

COPY . .

RUN npm run build


FROM node:18.15.0-alpine as runtime

WORKDIR /app

COPY --from=builder ./src/node_modules/ /app/node_modules/
COPY --from=builder /src/dist .

RUN adduser --disabled-password -u 10001 \
    --home /app \
    --gecos '' appuser && chown -R appuser:appuser /app

USER appuser

EXPOSE 3000

ENTRYPOINT [ "node", "./main.js" ]
