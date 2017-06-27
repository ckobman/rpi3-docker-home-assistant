
[![Docker Repository on Quay.io](https://quay.io/repository/mitchese/rpi3-docker-home-assistant/status "Docker Repository on Quay.io")](https://quay.io/repository/mitchese/rpi3-docker-home-assistant)


# mitchese/rpi3-docker-home-assistant:0.47.1

- [Introduction](#introduction)
  - [Installing Docker](#docker-on-your-raspberry)
  - [Running this image](#running-the-image)
  - [Persistent Storage](#persistent-storage)
  - [Troubleshooting](#Troubleshooting)
  - [Building the image yourself](#building-the-image-yourself)
- [Upgrades](#upgrades)

# Introduction

This is a container intended to run on RPI3 hosting the home-assistant project for home automation. This tries to be as close as possible to the official images and includes the RPI-GPIO as well as all modules found in the regular x86_64 image for home-assistant.

Unfortunately, Docker Hub is unable to automatically build ARM images, so this is not an automated build. See the build instructions below, as well as clone this repository from [github](https://github.com/mitchese/rpi3-docker-home-assistant/)

The instructions below are split into two sections, one to get Docker running on a Raspberry Pi, and the second to get this image running on the Raspberry Pi with Docker.

## Docker on your Raspberry

Docker is an amazing virutalization/containerization solution, which allows rapid development and deployment. You can use Docker to run other tools such as Node-Red along side home-assistant. This how-to is a compressed form of the full instructions from the Hypriot blog, which can be found [here](https://blog.hypriot.com/getting-started-with-docker-on-your-arm-device/) for Windows, OSX and Linux. 

You will need 
  - an SD Card at least 4Gb, but 8Gb or larger is recommended
  - A copy of Win32 Disk Imager, found [here](https://sourceforge.net/projects/win32diskimager/)
  - A copy of the latest Hypriot OS, which can be found [here](https://blog.hypriot.com/downloads/) (download the latest one, like hypriotos-rpi-v1.4.0.img.zip) 
  - If you're a debian user, you can also download a .deb package from the download page

Download and extract the Hypriot OS image from the link above. 

Start Win32 Disk Imager, and choose the .img file you extracted above as the source image. In the device, locate your SD Card. **Ensure the SD Card is chosen as your target device. Getting this wrong may accidentally install Hypriot overtop of Windows!** 

That's it! Once the Win32 Disk imager is compete, you can safely remove the SD card from Windows and you're done. Insert it into your Raspberry Pi, connect the power and it should boot. You can login with the username **pirate** and password **hypriot**, either with a keyboard/monitor attached to the Raspberry Pi, or via the Putty SSH Client - (download [here](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html))

## Running the Image

Type this in the command line 

```
docker run -d -p 8123:8123 --name="home-assistant" mitchese/rpi3-docker-home-assistant:latest
```

which should give some output like this (where ```6bd...``` is the container ID): 
```
[rancher@rancher ~]$ docker run -d -p 8123:8123 --name="home-assistant" mitchese/rpi3-docker-home-assistant:latest
6db05eeee486aa56f4e5dbe81da6866692986d47eccdc94a2213b5fe8f364c29
[rancher@rancher ~]$
```

You should now (after ~30 seconds of waiting) be able to connect to http://<your_pi_ip>:8123/ and see the initial "Welcome Home" card. 

### Persistent Storage

Docker containers are not meant to have any permanent data inside the container itself. Any upgrades or changes in the container will lose your entire configuration, since a clean container is always created. You can resolve this by mounting the config directory outside of your container.  Use the ```-v``` option below to accomplish this. If you're planning on using any presence detection or HUE Bridge emulation, you will also need to replace ```-p 8123:8123``` with ```--net=host``` as shown below  

```
mkdir -p /var/docker-data/homeassistant
docker run -d -v /var/docker-data/homeassistant:/config --net=host --name="home-assistant" mitchese/rpi3-docker-home-assistant:latest
```

This will mount ```/var/docker-data/homeassistant``` on the parent machine (hypriot or raspbian) to the "/config" location inside the container. The parent machine folder can be any folder; however, it must be mounted under ```/config``` in the container.  This way, any new versions can mount this same directory and preserve the configuration and SQLite DB. 


### Troubleshooting

If anything goes wrong, you can use the following commands to help diagnose the issue. Please open an issue on Github if something isn't working as described. Note that the container ID can be shortened, so instead of typing ```6db05eeee486aa56f4e5dbe81da6866692986d47eccdc94a2213b5fe8f364c29``` you can type just ```6bd``` (your container ID will be different)

  - ```docker logs <container ID>``` will show the output from Home Assistant 
  - ```docker ps -a``` will show all containers and their current state (running, stopped)
  - ```docker images``` will show all container images 
  - ```docker exec -ti <container ID> bash``` will create an interactive bash shell inside the container
  - ```docker run -d -p 8123:8123 mitchese/rpi3-docker-home-assistant:0.46``` will run a specific version of Home-Assistant (0.46) 

This image is configured to use /config as the configuration location. You probably want to mount this 

### Building the image yourself

This is not necessary, but if you're interested in building the image yourself then you'll need a raspberry pi with both Docker and git installed. Run the following command: 

```bash
docker build -t mitchese/rpi3-docker-home-assistant:latest github.com/mitchese/rpi3-docker-home-assistant
```


# Upgrades

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
  docker rm home-assistant
  ```

  4. Start the updated image

  ```bash
  docker run -d --name="home-assistant" \
    --volume /var/docker-data/homeassistant:/config \
    --net=host mitchese/rpi3-docker-home-assistant:latest
  ```
