
[![Docker Repository on Quay.io](https://quay.io/repository/mitchese/rpi3-docker-home-assistant/status "Docker Repository on Quay.io")](https://quay.io/repository/mitchese/rpi3-docker-home-assistant)


# mitchese/rpi3-docker-home-assistant:0.46.1

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
  - [Changelog](Changelog.md)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Deploy Keys](#deploy-keys)
  - [Trusting SSL Server Certificates](#trusting-ssl-server-certificates)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)
- [List of runners using this image](#list-of-runners-using-this-image)

# Introduction

This is a container intended to run on RPI3 hosting the home-assistant project for home automation. This tries to be as close to the official images and includes the RPI-GPIO as well as all modules found in the regular x86_64 image for home-assistant.

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

A finished image of this is available on [Dockerhub](https://hub.docker.com/r/mitchese/rpi3-docker-home-assistant) and is the recommended method of installation.

```bash
docker pull mitchese/rpi3-docker-home-assistant:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t mitchese/rpi3-docker-home-assistant:latest github.com/mitchese/rpi3-docker-home-assistant
```

## Quickstart

You will need to develop your own configuration.yaml according to your home. You can clone my configuration as a starting point from my home-assistant configuration repository.

```bash
docker run -d --name="home-assistant" \
  --volume /your-config-path:/config \
  --volume /etc/localtime:/etc/localtime:ro \
  --net=host mitchese/rpi3-docker-home-assistant
```

If you don't require host networking (for example, if you're not doing any traffic sniffing for presence detection, HUE Bridge emulation, etc.) then you can skip `--net=host` and replace with `--port 5000:5000`

```bash
docker run -d --name="home-assistant" \
  --volume /your-config-path:/config \
  --volume /etc/localtime:/etc/localtime:ro \
  --port 5000:5000 mitchese/rpi3-docker-home-assistant
```

## Persistence

Everything in home-assistant is stored in the configuration folder; By default it will setup a SQLite database which is under home_assistant.db in this folder. 

Therefore, the only volume which needs to outlive the container is the `your-config-path` foldewr.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

## Letsencrypt SSL Certificates

If you want to provide access via https with valid certificates, you can use the letsencrypt certbot from quay to generate the certificate.

You must first forward port 80 from your router to your docker container, in order to pass the certificate authenticaion checks. Then: 

```bash
sudo mkdir /your-config-path/certs /var/lib/letsencrypt
sudo docker run -it --rm --port 80:80 --name certbot \
                --volume "/your-config-path/certs:/etc/letsencrypt" \
                --volume "/var/lib/letsencrypt:/var/lib/letsencrypt" \
                quay.io/letsencrypt/letsencrypt:latest certonly \
                --standalone --standalone-supported-challenges http-01 \
                --email your@email.address -d hass-example.muzik.ca
```

To upgrade the certificate (Every 90 days): 
```bash
./certbot-auto renew --quiet --no-self-upgrade --standalone \
                     --standalone-supported-challenges http-01
```

To use the generated certificates: 
```
http:
  api_password: YOUR_SECRET_PASSWORD
  ssl_certificate: /config/certs/live/hass-example.muzik.ca/fullchain.pem
  ssl_key: /config/certs/live/hass-example.muzik.ca/privkey.pem
```


# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull mitchese/rpi3-docker-home-assistant:latest
  ```

  2. Stop the currently running image:

  ```bash
  docker stop home-assistant
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v home-assistant
  ```

  4. Start the updated image

  ```bash
  docker run -d --name="home-assistant" \
    --volume /your-config-path:/config \
    --volume /etc/localtime:/etc/localtime:ro \
    --net=host mitchese/rpi3-docker-home-assistant:latest
  ```
