#!/bin/bash

docker rmi redis:5.0.14-local
docker build -t redis:5.0.14-local .