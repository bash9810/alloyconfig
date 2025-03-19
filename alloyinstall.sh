#!/bin/bash
apt -y install gpg acl
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor |  tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" |  tee /etc/apt/sources.list.d/grafana.list
 apt-get update &&  apt-get -y install alloy
echo 'local.file_match "local_files" {
     path_targets = [{"__path__" = "/var/log/**/*.log"}]
 }

loki.source.file "log_scrape" {
    targets    = local.file_match.local_files.targets
    forward_to = [loki.process.filter_logs.receiver]
}

loki.process "filter_logs" {
    stage.drop {
        source = ""
        expression  = ".*Connection closed by authenticating user root"
        drop_counter_reason = "noisy"
        }
     forward_to = [loki.write.default.receiver]
 }

logging {
  level = "warn"
  write_to = [loki.write.default.receiver]
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
  disable_collectors       = ["mdadm"]
}

loki.write "default" {
        endpoint {
                url = "http://loki.aspenfibernetworks.com:3100/loki/api/v1/push"
}
}

tracing {
  sampling_fraction = 0.1
  write_to          = [otelcol.exporter.otlp.default.input]
}

otelcol.exporter.otlp "default" {
    client {
        endpoint = "loki.aspenfibernetworks.com:4317"
    }
}
' > /etc/alloy/config.alloy
usermod -aG systemd-journal alloy
setfacl -R -m u:alloy:rX /var/log
setfacl -R -m d:u:alloy:rX /var/log
systemctl start alloy
systemctl enable alloy.service
