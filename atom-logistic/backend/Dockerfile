FROM node:20-alpine
RUN apk add --no-cache curl

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

EXPOSE 80
ENV PORT=80

CMD ["node", "server.js"]
