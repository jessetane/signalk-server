ARG IMAGE_BASE=node
FROM $IMAGE_BASE:16

#COPY requires one valid argument, second can be nonexistent
COPY empty_file tmp*/qemu-arm-stati[c] /usr/bin/

RUN apt-get update && apt-get -y install libavahi-compat-libdnssd-dev

RUN groupadd -r i2c -g 998 && groupadd -r spi -g 999 && usermod -a -G dialout,i2c,spi node
USER node
RUN mkdir -p /home/node/signalk
WORKDIR /home/node/signalk

COPY --chown=node:node . .

RUN npm install

WORKDIR /home/node/signalk/packages/server-api
RUN npm run build
WORKDIR /home/node/signalk/packages/server-admin-ui
RUN npm run build

WORKDIR /home/node/signalk
RUN npm run build
RUN mkdir -p /home/node/.signalk

EXPOSE 3000
ENV IS_IN_DOCKER true
WORKDIR /home/node/.signalk
ENTRYPOINT /home/node/signalk/bin/signalk-server --securityenabled
