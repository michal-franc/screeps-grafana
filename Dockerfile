FROM node:14-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY index.coffee ./
COPY src ./src

CMD ["./node_modules/.bin/coffee", "index.coffee"]
