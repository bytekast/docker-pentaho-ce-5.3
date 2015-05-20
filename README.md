docker-pentaho-ce-5.3
==============

## Base image for running Pentaho BISERVER CE software within a Docker Container

### Building
```
docker build -t bytekast/pentaho-ce-5.3 .
```

### Running

`bytekast/pentaho-ce-5.3` is designed to run as a dameon, which you can ssh into and intall Pentaho.

To start a new container, run
```
docker run -d -p 2222:22 -p 8888:8080 -e AUTHORIZED_KEYS="`cat ~/.ssh/id_rsa.pub`" bytekast/pentaho-ce-5.3
```

You are now able to ssh directly into the container with your ssh keys.
```
ssh -p 2222 root@docker_host
```

To check the biserver logs, ssh to the container and run
```
tail -f /home/pentaho/biserver-ce-5.3.0.0-213/biserver-ce/tomcat/logs/catalina.out
```
