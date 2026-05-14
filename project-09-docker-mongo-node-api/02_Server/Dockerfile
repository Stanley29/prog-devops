FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY wait-mongo.sh .
COPY server.js .

RUN apk add --no-cache curl

RUN sed -i 's/\r$//' wait-mongo.sh
RUN chmod +x wait-mongo.sh

EXPOSE 4000

CMD ["sh", "wait-mongo.sh"]
