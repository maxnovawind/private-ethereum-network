# Setup monitoring

## Step 1: Define the key metrics to monitor

Tracking the Besu nodes:
- CPU/memory/PVC usage
- The time of the last block is beneficial for knowing if the node is still active.
- Block propagation time: time between the block creation and the block propagation to the other nodes.
- The average block time is useful for determining if the node is still active. It's generally related to CPU usage in real-world contexts.
- `ethereum_count_peers`/`ethereum_peer_limit` is useful for understanding the peering capacity of the node.
- Events of Kubernetes pods for tracking the pods' CrashLoopBackOff events
- Throughput (TPS): number of blocks per second * avg(number of transactions per block)Deploy the kube-prometheus-stack with the right values.


## Step 2: Configure this key metrics in the kube-prometheus-stack values.yaml/values.local.yaml

parameter in the values.yaml/values.local.yaml file:
```yaml
overridesMonitoringTemplate:
  besu:
    # calculate the number of transactions per second
    networkThroughputThreshold: 10
    # calculate the number of blocks per second
    chainStalledThreshold: 60
    # calculate the time of the last block
    blockNetworkTimeThreshold: 30
    # calculate the ratio of current peer count to peer limit
    peerRatioThreshold: 0.7
```

### Extra: Example of alertmanager configuration:

```yaml
global:
  resolve_timeout: 5m
  # slack webhook need to be configure
  slack_api_url: ""
route:
  group_by: ["alertgroup", "job"]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: "slack-monitoring"
  routes:
    ## Standard on-call routes
    - matchers:
        - severity=~"info"
      receiver: slack-staging
      group_wait: 10m
      group_interval: 1h
      repeat_interval: 24h
      continue: false
    - matchers:
        - severity=~"warning"
      receiver: slack-staging
      group_wait: 5m
      group_interval: 15m
      repeat_interval: 6h
      continue: false
    - matchers:
       - severity=~"critical"
      receiver: slack-staging
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
      continue: false
inhibit_rules:
  - target_matchers:
      - severity=~"warning"
    source_matchers:
      - severity=critical
    equal:
      - namespace
      - alertname

receivers:
  - name: "slack-staging"
    slack_configs:
      - channel: "#alerting-infra"
        send_resolved: true
        # TODO: add the slack webhook
        api_url: ""
```

This Alertmanager configuration sets a global resolve timeout of 5 minutes and includes a placeholder for the Slack webhook URL. Alerts are grouped by "alertgroup" and "job" labels, with a default receiver of "slack-monitoring". The configuration specifies different handling rules based on alert severity: "info" alerts are sent to the `slack-staging` receiver with a 10-minute wait and 1-hour interval, "warning" alerts with a 5-minute wait and 15-minute interval, and "critical" alerts with a 30-second wait and 5-minute interval. Additionally, inhibit rules prevent "warning" alerts from being sent if a "critical" alert is active for the same cluster, namespace, and alert name. The `slack-staging` receiver is configured to send alerts to the "#alerting-infra" Slack channel, but the actual Slack webhook URL needs to be added.


## Step 3: Deploy the kube-prometheus-stack and metrics-server helm chart

Go to monitoring-apps in argocd and install the kube-prometheus-stack and metrics-server.

## Step 4: Deploy the loki-stack helm chart

Go to monitoring-apps in argocd and install the loki-stack.


## Step 5: Connect to the grafana dashboard

Access the grafana dashboard with the following command and use default credentials `login: admin` and `password: prom-operator`:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 8081:80
```

## Step 6: Enjoy the dashboard

[[Back To Architecture]](./Architecture-monitoring.md) [[Go To README]](../README.md)
