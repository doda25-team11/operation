# Continuous Experimentation

We introduced a new Canary version (v2), where 90% of the traffic is going to the stable version (v1), and 10% to the Canary version.

---

## Hypothesis

The experiment evaluates the following falsifiable hypothesis:
  
Deploying the new model version in v2 reduces the p95 message classification latency by at least **20%** compared to v1.

---

## 4. Metrics

The experiment relies on the following metrics. 

- **`sms_checker_actions_total{action, result, channel, version}`** (Counter)  
  Counts user-facing actions in the app and their outcomes. 

- **`sms_checker_classify_latency_seconds{channel, model_version, version}`** (Histogram)  
  Records the **end-to-end time** spent classifying a message (per request) and exposes bucketed latency for percentiles (p50/p95/p99).  

- **`sms_checker_in_flight_requests{component, version}`** (Gauge)  
  Shows the **current number of ongoing classification requests** at scrape time (concurrency).  

- **`sms_checker_active_sessions{channel, version}`** (Gauge)  
  Approximate number of active user sessions (or active usage windows) at the moment.  

---

## Experiment Setup

---

## Results

---

## Conclusion
