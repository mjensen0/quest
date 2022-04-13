#Build image from node base
FROM node:17-alpine
WORKDIR /app

#Set Secret Word
ENV SECRET_WORD="baboons"

#Add project files to docker image
ADD ./package.json /app/
ADD ./src /app/src
ADD ./bin /app/bin

#Install npm modules
RUN cd /app
RUN npm install

#Start node application
CMD npm start

#Expose port
EXPOSE 3000