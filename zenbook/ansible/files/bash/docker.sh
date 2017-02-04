#!/bin/bash



docker-update-ansible(){
        local DATE=`date +%Y%m%d`

        docker build -t fellah/ansible:$DATE --no-cache $HOME/Devel/docker/ansible

        docker tag fellah/ansible:$DATE fellah/ansible:latest
}


docker-update-archlinux(){
        local DATE=`date +%Y%m%d`

        docker pull base/archlinux:latest

        docker build -t fellah/archlinux:$DATE --no-cache $HOME/Devel/docker/archlinux

        docker tag fellah/archlinux:$DATE fellah/archlinux:latest
}

docker-update-ubuntu(){
	local DATE=`date +%Y%m%d`

	docker pull ubuntu:latest

	docker build -t fellah/ubuntu:$DATE --no-cache $HOME/Devel/docker/ubuntu

	docker tag fellah/ubuntu:$DATE fellah/ubuntu:latest
}



docker-cleanup(){
	docker rm --volumes $(docker ps --all --filter="status=exited" --quiet=true)

	docker rm --volumes $(docker ps --all --filter="status=dead" --quiet=true)

	docker rmi $(docker images --filter="dangling=true" --quiet=true)
}
