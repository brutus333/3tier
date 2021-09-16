FROM node:lts-alpine3.11
ADD . /opt
WORKDIR /opt
RUN ["npm", "install"]
CMD ["npm", "start"]
EXPOSE 80/tcp