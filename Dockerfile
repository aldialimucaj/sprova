FROM node:11
COPY ./server /server
COPY ./web/dist/sprova /web
WORKDIR /server
EXPOSE 8181
CMD [ "npm", "start" ]
