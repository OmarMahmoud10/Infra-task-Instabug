# Infrastructre task Instabug
## docker image
```
FROM golang:1.20.5-alpine3.18 AS builder

COPY db.go go.sum go.mod main.go /opt/code/

WORKDIR /opt/code

RUN go build -o internship

# stage 2 running the app
FROM alpine:latest

COPY --from=builder /opt/code /

ENTRYPOINT [ "./internship" ]
```
in order to make the image as lightweight as possible I used multi-stage builds, which resulted in an image with a size of 15 MB 

---
##  docker-compose
```
version: '3'
services:
  internship:
    image: internship-go
    environment:
      - MYSQL_HOST=mysql-db 
      - MYSQL_PORT=3306
      - MYSQL_USER=root
      - MYSQL_PASS=123456789
    ports:
      - 9090:9090
    depends_on:
      mysql-db:
        condition: service_healthy
  
  mysql-db:
    image: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=123456789
    volumes:
      - type: volume
        source: mysql-volume
        target: /var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 3

    ports:
      - 7000:3306

volumes:
  mysql-volume:
```
These are the configurations inside my docker-compose file:
Here I have 2 services `internship-go` and `mysql-db` with a volume called `mysql-volume` that is mounted to the `mysql-db` container to ensure data persistency
I also used a healthcheck condition to make sure that the `internship-go` will run after the `mysql-db` container is up and the service is running and ready to recieve connections.

---
## Application architecture to run on kubernetes
To run this app on a kubernetes cluster I created this setup

### Internship-go app
for the internship-go app I created:
- internship-go-deployment.yml
To deploy the `internship-go` app and to provide high availability 

- internship-go-service.yml 
This is an internal network of clusterIP type be able to have a persistent connection with `internship-go` app during restarts

- internship-go-ingress.yml
Ingress is used to be able to access the `internship-go` app from the browser using Domain name, without exposing its ip address, it's also used to enable HTTPS to make the traffic more secure 

- internship-go-autoscale.yml
I used horizontal autoscaling to automatically scale up pods when the cpu usage reaches 50%


### mysql
for mysql I created:
- mysql-deployment.yml
- mysql-service.yml

In order to have a persistent volume I created
- persistent voulme claim
to claim a pv for the `mysql` pod based on its defined specs

- persistent volume
I user hostPath to mount storage to my k8s cluster

I also created 
- mysql-configmap.yml
this contains the 3 environment variables needed be the `internship-go` pod to connect to the database
  - MYSQL_USER
  - MYSQL_HOST
  - MYSQL_PORT
 
- mysql-secret.yml
this is a secret of type `Opaque` to manage credentials used to connect to the `mysql-db`, in this case it contins the root password of the database

- internship-go-tls-secret.yml 
this is a secret of type `tls` to store ssl certificate and key used with ingress to use HTTPS

> you need to create these 2 secret files locally and store the needed credentials 




---
## Jenkinsfile
This is a pipeline that consists of 4 stages:
- checkout the code from the git repo
- login to docker
- build the image
- push the image to docker hub

2 post build stages:
- logout from docker
- send an email notification in case of build failure

> make sure to configure the jenkins agent with the needed build tools



---
## This is step-by-step guide on how to get internship-go app up and running on your machine using 3 different ways:
1. **Manully using `docker run` command**
2. Using `docker-compose`
3. Using `helm chart` 

---
## 0. Clone the repo
```
git clone https://github.com/OmarMahmoud10/Infra-task-Instabug.git
```
---
## 1. Docker run

1. Navigate to the location of the repo
2. build the image
```
docker build -f Dockerfile . -t <image_name>
```
3. Run mysql container 
```
docker run -d -e MYSQL_ROOT_PASSWORD=<password> -v mysql-volume:/var/lib/mysql -p <db_host_port>:3306 --name mysql-db mysql
```
> note: if you have a mysql instance running on your local machine, change the host port
4. Run the go app contaier with the 4 environment variables required to have a successful connection with the mysql-db container
  - MYSQL_HOST
  - MYSQL_PORT
  - MYSQL_USER
  - MYSQL_PASS
```
docker run -d -e MYSQL_USER=<user_name> -e MYSQL_PORT=<db_host_port> -e MYSQL_HOST=mysql-db -e MYSQL_PASS=db_password -p <go_host_port>:9090 --link mysql-db:mysql-db omarmahmoud10/internship-go
```
5. check the connection by going to `localhost:<go_host_port>/healthcheck`
> stop the containers `docker stop <container_id>`
---


### 2. Using docker-compose up
1. run the file using `docker-compose up`
2. check the connection by going to `localhost:<go_host_port>/healthcheck`
---


## Using Helm 
To run the internship-go app on a kubernet
```
helm install internship-go-release internship-go/
```

---

![Alt text](image link)


