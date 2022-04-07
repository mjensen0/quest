FROM node:17-alpine
WORKDIR /app
ENV SECRET_WORD="baboons"
ADD ./package.json /app/
ADD ./src /app/src
ADD ./bin /app/bin
RUN cd /app
RUN npm install
CMD npm start
EXPOSE 3000