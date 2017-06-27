FROM sdhibit/rpi-raspbian:latest
MAINTAINER Sean Mitchell docker@muzik.ca

RUN apt-get update && apt-get -y upgrade && apt-get -y install python3 wget python3-pip python3-dev locales libffi5-dev libssl-dev libtiff5-dev libjpeg-dev zlib1g-dev \
                                         libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk libxml2-dev libxslt1-dev zlib1g-dev \
                                         libmysqlclient-dev libpq-dev libncurses5-dev libbz2-dev libsqlite3-dev curl libxrandr-dev swig swig2.0 x11proto-randr-dev vim\
                                         && rm -rf /var/lib/apt/lists/

# correct locales 
RUN sed -i -e "s/# en_US.*/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# Get latest version of python and compile
RUN wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz && \
    tar -zxvf Python-3.6.1.tgz && cd Python-3.6.1 && ./configure && make && make install  && cd .. && rm -rf Python-3.6.1 Python-3.6.1.tgz

# Uncomment any of the following lines to disable the installation.
#ENV INSTALL_TELLSTICK no
#ENV INSTALL_OPENALPR no
#ENV INSTALL_FFMPEG no
#ENV INSTALL_LIBCEC no
#ENV INSTALL_PHANTOMJS no
#ENV INSTALL_COAP_CLIENT no

VOLUME /config

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy build scripts
COPY Docker/ virtualization/Docker/
RUN wget -O - https://ftp-master.debian.org/keys/archive-key-8.asc | apt-key add - && wget -O - https://ftp-master.debian.org/keys/archive-key-8-security.asc | apt-key add -
RUN virtualization/Docker/setup_docker_prereqs

COPY requirements_all.txt requirements_all.txt
RUN pip3.6 install --upgrade pip setuptools

RUN /usr/local/bin/pip3.6 install -r requirements_all.txt 

RUN /usr/local/bin/pip3.6 install mysqlclient psycopg2 uvloop cchardet

RUN /usr/local/bin/pip3.6 install homeassistant==0.47.1
# Copy source
#COPY . .

CMD [ "python3.6", "-m", "homeassistant", "--config", "/config" ]
