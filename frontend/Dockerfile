FROM node:22-alpine3.22 AS build-stage
WORKDIR /TimeManager
COPY package*.json ./
RUN npm install
COPY . .
ARG API_URL
ENV API_URL=$API_URL
RUN npm run build

FROM nginx:alpine
RUN apk upgrade --no-cache
COPY --from=build-stage /TimeManager/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
