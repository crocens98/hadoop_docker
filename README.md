

docker build -t croken98/hadoop-hive-local .

docker run --privileged --add-host kafka-0.kafka-headless.default.svc.cluster.local:192.168.65.2 -ti -p 8080:8080/tcp -p 9870:9870 -p 8088:8088 -v /home/viktar_zinkou:/external --hostname hadoop-host --ip 172.17.0.2 --name hadoop-container croken98/hadoop-hive-local

docker exec -ti  hadoop-container bash

First run: ./init-hdfs.sh



kubectl apply -f pod.yaml
kubectl exec --tty -i hadoop-single-node --namespace default -- bash
