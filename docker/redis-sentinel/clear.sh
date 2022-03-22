#/bin/bash

docker-compose down

docker images | grep redis_ | awk '{print $3}' | xargs -n1 docker rmi
