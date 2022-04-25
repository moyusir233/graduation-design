#!/bin/bash
docker network create elastic
docker run --name es-node01 --net elastic -p 9200:9200 -p 9300:9300 -d \
-e "xpack.security.http.ssl.enabled=false" \
-e "xpack.security.enabled=false" \
-e "node.name=es01" \
-e "cluster.initial_master_nodes=es01" \
docker.elastic.co/elasticsearch/elasticsearch:8.1.2
docker run --name kib-01 --net elastic -p 5601:5601 -d docker.elastic.co/kibana/kibana:8.1.2
