~~ob~~SERVA~~bility~~ Project
==============

Hightly Persistence Observability EKL Stack (Filebeat, Redis, LogStash & Elasticsearch)

![Microservices Federation](./docs/flow.png?raw=true "Graph of Microservices Federation")

# Installation

1. First, clone this repository:

```bash
git clone https://github.com/nietzscheson/serva
```
2. Init the project building and running the containers:
```bash
docker compose up --build -d
```
3. This results in the following running containers:
```bash
docker compose ps
 Name           State          Ports
--------------------------------------------------------------------------------
app             Up             
elasticsearch   Up (healthy)   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 9300/tcp
filebeat        Up (healthy)   
kibana          Up (healthy)   0.0.0.0:5601->5601/tcp, :::5601->5601/tcp
logstash        Up (healthy)   0.0.0.0:5044->5044/tcp, :::5044->5044/tcp, 9600/tcp
redis           Up (healthy)   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp
```
4. Kibana is running in: [localhost:5601](http://localhost:5601)

5. Create an Index Pattern:
- Go to "Stack Management" > "Index Patterns".
- Create a new index pattern with logstash-*.
- Select @timestamp as the time field.
6. Explore the Data:
- Navigate to "Discover" and select the logstash-* index pattern.
- You should see the logs sent from Filebeat through Redis and Logstash.

