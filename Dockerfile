#Primera Etapa
FROM node:fermium-alpine as build-step

RUN mkdir -p /app

WORKDIR /app

COPY package.json /app

RUN npm install

COPY . /app

RUN npm run build --prod

#Segunda Etapa
FROM nginx:1.24.0-alpine
COPY --from=build-step /app/dist /usr/share/nginx/html