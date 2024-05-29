# prometheus-node-exporter
Prometheus node-exporter installer

## Installation

- Clone the repository

```
git clone 
```
- Change into the diretory

```
cd prometheus-node-exporter
```

- Run installer script with `sudo` privileges

```
sudo ./install_node_exporter
```

Check status of the node-exporter service to make sure it is running
```
sudo systemctl status node-exporter.service
```
The output should look like this

`● node_exporter.service - Prometheus Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) ...
     ....`


## Overview metrics

When the exporter is running, open browser and go to `http://localhost:9100` or `http://<your-server-ip>:9100/metrics`

The browser should respond with metrics collected by the exporter.

In case you don't get reponse, please check your firewall.


