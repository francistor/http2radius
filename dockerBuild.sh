#!/bin/bash

version=0.2

# Better at the beginning
echo "DockerHub password"
docker login --username=francistor || exit 1

# Generate docker image
docker build --file Dockerfile --build-arg version=$version --tag http2radius:$version .

# Publish to docker hub
docker tag http2radius:$version francistor/http2radius:$version
docker push francistor/http2radius:$version

# Execute inine and delete 
# docker run --rm -it -p 1812:1812 -p 1813:1813 -p 8080:8080 --name http2radius francistor/http2radius:0.2

# Execute detached
# docker run --name http2radius -p 1812:1812 -p 1813:1813 -p 8080:8080 -d francistor/http2radius:0.2

# -v /home/francisco/mysql/conf-main.d:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD 