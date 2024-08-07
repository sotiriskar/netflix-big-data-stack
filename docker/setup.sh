#!/bin/bash

docker network create netflix-net

# Navigate to docker/kafka directory and run docker-compose up in detached mode
cd kafka
docker compose up -d

echo "Kafka is up and running"

# Navigate to docker/druid directory and run docker-compose up in detached mode
cd ../druid
docker compose up -d

echo "Druid is up and running"

# Navigate to docker/minio directory and run docker-compose up in detached mode
cd ../minio
docker compose up -d

echo "Minio is up and running"

cd ../

# if not exists
# Clone the Apache Superset repository
if [ ! -d "superset" ]; then
    git clone https://github.com/apache/superset
fi

# Enter the repository you just cloned
cd superset

# Fire up Superset using Docker Compose
docker compose -f docker-compose-image-tag.yml up -d

# create folder named jars in the root directory & download the required jars
cd ../../
# if folder already exists and contains jars, skip downloading
if [ -d "jars" ]; then
    echo "Jars folder already exists"
else
    mkdir jars
    cd jars
    curl -o flink-sql-connector-kafka-1.15.0.jar https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/1.15.0/flink-sql-connector-kafka-1.15.0.jar

    echo "Downloaded jar files"
fi

docker exec -it broker-kafka kafka-topics --create --topic user_sessions --partitions 1 --replication-factor 1 --bootstrap-server localhost:9092 && break || echo "Retrying to create user_sessions..."
docker exec -it broker-kafka kafka-topics --create --topic processed_sessions --partitions 1 --replication-factor 1 --bootstrap-server localhost:9092 && break || echo "Retrying to create processed_sessions..."

echo "Attempted to create topics user_sessions and processed_sessions"
