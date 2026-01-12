# SMS Checker - Operation

This repository is the main entry point for running the complete SMS Checker application. It contains the `docker-compose.yml` file and the documentation required to start the application (`README.md`).

## High-level architecture
The SMS Checker application is designed to classify text messages as spam or ham (valid) using a machine learning model. The architecture consists of several independent components that communicate via REST APIs.  
- [app](https://github.com/doda25-team11/app): Web frontend and API gateway service. 
- [model-service](https://github.com/doda25-team11/model-service): Python backend hosting the machine learning model.
- [lib-version](https://github.com/doda25-team11/lib-version): Version-aware Maven library reused by the app. 
- [operation](https://github.com/doda25-team11/operation): This repository - Orchenstrates all components using Docker Compose. 

## Prerequisites
Before running the application, ensure you have: 
- Docker (recommended: version 28 or later)
- Docker Compose (recommended: v2 or later)

## Configuration
The application deployement is configured using environment variables defined in the `.env` file. You can customize the deployment by modifying these values.
### Parameters
- **APP_IMAGE:** The tag of the frontend application container image. 
- **MODEL_IMAGE:** The tag of the backend model-service container image.
- **APP_PORT:** THe port on the host machine where the application will be accessible. 
- **MODEL_SERVICE_PORT:** The internal port used by the model service (not exposed to the host)

## How to run
1. Clone this repository
```bash
git clone [https://github.com/doda25-team11/operation.git](https://github.com/doda25-team11/operation.git)
cd operation
``` 
2. Configure the environment (optional):
Review the `.env`file to ensure the image names and ports match your requirements. 

3. Start the application
Run the following command to pull the image and start the containers.
```bash
docker compose up
```
4. Access the application
Once the containers are running, access the SMS Checker frontend in your browser at: `http://localhost:8080/sms` (or the port defined in `APP_PORT`)

5. Stop the application
To stop tand remove the containers, run:
```bash
docker compose down
```

## Understanding the Codebase
To understand the architecture and deployment of the SMS Checker application, here are the most relevant files across the different components:

***

# Operation (Current Repository)

These files define deployment and environment settings:

* **`docker-compose.yml`**: Orchestrates all services, networks, volumes, and dependencies.
* **`.env`**: Configures image tags, ports, and user IDs for volume permissions.
* **`models/`**: The mounted host directory used as a local cache for model files.


### Local Kubernetes VMs (Assignment 2)

All provisioning lives in `provisioning-vm/` and is handled by Vagrant + Ansible.

```bash
cd provisioning-vm
```

Start the cluster (default provider, usually VirtualBox):
```bash
vagrant up
```
Start the cluster with a different provider (e.g. VMware):
```bash
vagrant up --provider=vmware_desktop
```

Re-run pro visioning after changing Ansible playbooks:
```bash
vagrant provision
```

Check VM status:
```bash
vagrant status
```

SSH into the controller, there are two ways. If your SSH keys work you can do this:
```bash
ssh vagrant@192.168.60.100
```
otherwise you can ssh into a VM doing:
```bash
vagrant ssh ctrl
```

Destroy all VMs:
```bash
vagrant destroy -f
```

### Helm Installation

**Note:** Before running the Helm commands, make sure your Kubernetes cluster is reachable with `kubectl` (from host). For example:
```bash
kubectl config current-context
kubectl get nodes
```
This should list a context (e.g `minikube`) and at least one node (e.g. `minikube` or `ctrl`).

If this returns a `current-context is not set` error, then add the `admin.conf` (located at `/provisioning-vm/.vagrant/`) as `KUBECONFIG` variable in the host
```bash
export KUBECONFIG=/<Path to repo>/operation/provisioning-vm/.vagrant/admin.conf
```

Install Helm 3 (follow the official docs for your OS).
Ex:
```bash
sudo snap install helm --classic
````

Make sure you are in …/helm/sms-checker
```bash
cd helm/sms-checker
```

Check the chart
```bash
helm lint .
helm template test-release .
```

Install / upgrade the release after changes
```bash
helm install test-release .
helm upgrade test-release .
```

To run with ingress (or set the variable to true in values.yaml)
```bash
helm upgrade test-release . \
  --set ingress.enabled=true \
  --set ingress.host="sms-checker.local"
```

To run this with port-forwarding: app and model
```bash
kubectl port-forward svc/test-release-sms-checker-app 8080:80
```
```bash
kubectl port-forward svc/test-release-sms-checker-model 8081:80
```

## Istio Traffic Management & Canary Release

This project uses **Istio** to expose the SMS Checker app via the Istio IngressGateway and to run a **canary release** with sticky sessions.

### Prerequisites

- Kubernetes cluster with Istio installed (and your computer pointing to this cluster)
- Istio IngressGateway is deployed and labeled. By default we expect:

  ```yaml
  istio.ingressGateway.selectorLabels:
    istio: ingressgateway
  ```
After the helm installation as described above (with the ghcr-credentials part), you should be able to run 
```bash
kubectl get svc -n istio-system istio-ingressgateway
```
This should return an entry that contains an EXTERNAL-IP. You should now be able to curl that ip.
```bash
curl -H "Host: sms.local" http://<EXTERNAL-IP>
```
To run with either control or canary versions, add the header "x-doda-exp: control" or "x-doda-exp: canary" 
```bash
curl -s \
    -H "Host: sms.local" \
    -H "x-doda-exp: control" \
    -H "Content-Type: application/json" \
    -d '{"sms": "win money FREE!!!"}' \
    http://<EXTERNAL-IP>/sms
```
**Troubleshooting**
Some problems I encountered
- If the status of your pods are ImagePullBackOff, you probably didn't set your credentials. Do so and restart/delete your pods
- Make sure "kubectl config current-context" returns a kuberenetes entry (not minikube like in-class)
- Make sure the kubeconfig file is up to date


***

# Monitoring

## Usability metrics (Prometheus)

### `sms_checker_actions_total{action, result, channel}` (Counter)
Counts user-facing actions in the app and their outcomes.  
Use it to understand **how users interact** with the system (e.g., how often they classify) and how often interactions **fail**.  
- `result`: outcome (`started`, `ok`, `error`)  

### `sms_checker_classify_latency_seconds{channel, model_version}` (Histogram)
Records the **end-to-end time** spent classifying a message (per request) and exposes bucketed latency for percentiles (p50/p95/p99).  
Use it to reason about **responsiveness** and whether users experience the system as “fast enough”.  
- `model_version`: deployed model version/tag (e.g., `current`)

### `sms_checker_in_flight_requests{component}` (Gauge)
Shows the **current number of ongoing classification requests** at scrape time (concurrency).  
Use it to detect spikes in simultaneous usage and correlate load with latency (potential usability degradation under load).  

### `sms_checker_active_sessions{channel}` (Gauge)
Approximate number of active user sessions (or active usage windows) at the moment.  
Use it as a proxy for **live engagement** and to detect drop-offs after changes/releases.  

To access the streams, refer to the http://sms.local/metrics.

## Alertmanager (Prometheus)
For the alertmanager, we use discord as the channel. Hereby, we make use of discord URL webhooks. 

### Create a discord webhook for your own server
To create a discord webhook for your own server, follow this guide: https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks.

### Set up a predefined discord webhook URL Secret
```bash
kubectl create secret generic alertmanager-discord-webhook -n default   --from-literal=webhook_url="<DISCORD_WEBHOOK_URL>/slack"
```
Then finish setting it up by running (if necessary):
```bash
helm upgrade --install test-release . -f values.yaml
```
You should see notifications in your discord channel.
# App 

This component defines the Java application and its build process:

* **`Dockerfile`**: Defines the multi-stage build for the final container image.
* **`pom.xml`**: Manages dependencies and reuses the `lib-version` package.
* **`FrontendController.java`**: The core controller that processes user requests and calls the Model Service.
* **`release.yml`**: The CI/CD workflow for building and publishing the container image.

***

# Model Service 

This component manages the ML model and prediction API:

* **`Dockerfile`**: Defines the Python environment, dependencies, and container setup.
* **`entrypoint.sh`**: Startup script that checks the volume and downloads the model from a release if files are missing.
* **`serve_model.py`**: The main application that loads the model and exposes the prediction REST API.
* **`model-release.yml`**: The dedicated workflow for automating model training and release.
* **`requirements.txt`**: Lists all necessary Python packages (e.g., Flask, scikit-learn).
