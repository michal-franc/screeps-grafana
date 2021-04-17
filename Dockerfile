FROM node:4-onbuild

WORKDIR /app

COPY package.json .
RUN npm install

COPY stats.js index.coffee ./
COPY src ./src

CMD ["./node_modules/.bin/coffee", "index.coffee"]