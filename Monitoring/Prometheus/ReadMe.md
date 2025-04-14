# Notes on Prometheus

I set up a mixture of two guides

## Setting up the prometheus itself
due to  [Prometheus on Proxmox using three LXC containers](https://pywkt.com/post/20230302-prometheus-and-grafana-on-proxmox)


Differences to this Guide:
- There's are files `prometheus/consoles/` `prometheus/console_libraries/` that can you copy to `/etc/prometheus/`

### Add configuration for each PVE node
extend `/etc/prometheus/prometheus.yml` with
```bash
#
# Proxmox
#
  - job_name: 'PVE 1'
    metrics_path: '/metrics'
    params:
        # This is the ip address of the proxmox server
        target: ['192.168.15.3']
    static_configs:
      # This is the container running pve_exporter
      - targets: ["192.168.15.3:9221"]
  - job_name: 'PVE 2'
    metrics_path: '/metrics'
    params:
        # This is the ip address of the proxmox server
        target: ['192.168.15.6']
    static_configs:
      # This is the container running pve_exporter
      - targets: ["192.168.15.6:9221"]
```
restart service
```bash
systemctl daemon-reload
systemctl restart prometheus
```

## Setting up a pve-exporter for each PVE node

for the *pve_exporter* I followed this [guide](https://phiptech.com/how-to-configure-prometheus-on-proxmox-for-monitoring/)

- Create a Linux User for Exporter
  ```bash
  useradd -s /bin/false pve-exporter
  ```
- Set Up Python Virtual Environment<br>
  Install the required Python package
  ```bash
  apt-get update
  apt-get install -y python3-venv
  ```
  Create a virtual environment<br>
  ```bash
  python3 -m venv /opt/prometheus-pve-exporter
  ```
- Install Prometheus Proxmox VE Exporter<br>
  Start Environment
  ```bash
  source /opt/prometheus-pve-exporter/bin/activate
  ```
  Install the exporter
  ```bash
  pip install prometheus-pve-exporter
  ```
  stop Environment
  ```bash
  deactivate
  ```
- Prepare & Create Configuration file<br>
  ```bash
  mkdir /etc/pve_exporter
  ```
  add to `/etc/pve_exporter/config.yaml`
  ```bash
  default:
    user: pve-exporter@pve
    token_name: exporter   # Token name created in the first step
    token_value: <Secret Token created in the first step>
    verify_ssl: false
  ```
  add to `/etc/default/pve_exporter`
  ```bash
  CONFIG_FILE=/etc/pve_exporter/config.yaml
  LISTEN_ADDR=192.168.15.6 # Replace with your PVE exporter's IP address
  LISTEN_PORT=9221
  ```
- Create and start systemd service
  copy to `/etc/systemd/system/pve_exporter.service`
  ```bash
  [Unit]
  Description=PVE Exporter
  Wants=network-online.target
  After=network-online.target
  
  [Service]
  User=pve-exporter
  Type=simple
  EnvironmentFile=/etc/default/pve_exporter
  ExecStart=/opt/prometheus-pve-exporter/bin/pve_exporter --config.file=/etc/pve_exporter/config.yaml --web.listen-address=192.168.15.6:9221
  
  [Install]
  WantedBy=multi-user.target
  ```
  relaod daemons and start exporter servide
  ```bash
  systemctl daemon-reload
  systemctl enable --now pve_exporter
  ```
## Setting up grafana
due to the first mentioned [guide](https://pywkt.com/post/20230302-prometheus-and-grafana-on-proxmox)

- Setup apt for Grafana<br>
  ```bash
  apt-get install -y apt-transport-https software-properties-common wget

  wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key

  echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
  ```
- Install Grafana<br>
  ```bash
  apt-get update

  apt-get install -y grafana-enterprise

  ```

- Start Grafana<br>
  ```bash
  systemctl daemon-reload
  systemctl enable --now grafana-server.service

  systemctl status grafana-server
  ```