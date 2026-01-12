# SMS Checker – Deployment Documentation

Stuff left to do in this file:
- Images -> I think there should be an image for each section: 2, 3, and 4
- Full readthrough that checks everything is correct, especially ports/links/commands/names/etc
- Some sections have not been fully done yet

## Table of Contents
- [Overview](#overview)
- [Deployment Structure](#deployment-structure)
- [Data Flow](#data-flow)
- [Monitoring](#monitoring)
- [Extra Information](#extra-information)

## Overview

### Project summary

This document describes the **final deployment architecture** of the SMS Checker system: an SMS spam/ham classifier
running on Kubernetes, with **Istio-based traffic management** (canary releases + sticky sessions) and support for
continuous experimentation. 

It consists of two main services:

- **app-service**  
  A web application exposing:
  - A simple landing page on `GET /`.
  - A REST API on `POST /sms` that accepts a JSON body (e.g. `{"sms": "example text"}`) and returns a classification
    result as JSON. Internally, it calls the model-service for predictions.

- **model-service**  
  A Python/Flask service exposing a `/predict` endpoint. It:
  - Loads a trained classifier and text preprocessing pipeline.
  - Accepts the SMS text as input and returns a result.

Both services are packaged as **Docker containers**, pushed to **GitHub Container Registry (GHCR)**, and deployed to a
Kubernetes cluster via a **Helm chart**. On top of Kubernetes, **Istio** is used to:

- Expose the app through an **Istio IngressGateway**.
- Run a **canary release** between version `v1` (stable) and `v2` (canary) of both app-service and model-service.
- Implement **sticky sessions** using a dedicated header so that “control” and “canary” users consistently see one version.


### Repositories

- **App** https://github.com/doda25-team11/app – Web frontend + REST API used by users to submit SMS texts.
- **Model Service** https://github.com/doda25-team11/model-service – Python/Flask service exposing `/predict` and loading the trained model.
- **Lib Version** https://github.com/doda25-team11/lib-version – Shared library used to centralize version information across components.
- **Operation** https://github.com/doda25-team11/operation – Operations and deployment repository.

### Infrastructure & tools

The system uses the following tools:

- **Kubernetes**:  To create and manage the cluster
- **Istio**: Service mesh used for:
  - Ingress.
  - Traffic management.
  - Canary release and sticky session routing.
- **Helm**: Used to package and deploy the SMS Checker chart into the cluster.
- **Docker**: Container runtime used to build images.
- **GitHub Container Registry (GHCR)**: Private container registry where app and model-service images are stored.
- **Vagrant + Ansible**: Used to provision the local Kubernetes cluster.
- **Prometheus + Grafana**: For continuous experimentation.
  

## Deployment Structure

### 2.1 Cluster and namespaces

The system runs on a small Kubernetes cluster with one control-plane node and two worker nodes:

- **Nodes**
  - `ctrl` – control-plane node (API server, scheduler, etcd).
  - `node-1`, `node-2` – worker nodes running the application pods.

- **Namespaces**
  - `default` – contains all SMS Checker workloads and Istio resources specific to this application.
  - `istio-system` – contains the Istio control plane (`istiod`) and the `istio-ingressgateway`.
  - Other namespaces created by provisioning (e.g. `kube-system`, `metallb-system`, `kubernetes-dashboard`) are
    used by the platform itself and are not modified by this project.

At a high level, the app and model pods run in the `default` namespace on the worker nodes, while the shared
Istio infrastructure runs in `istio-system`.

### 2.2 Application workloads (Deployments & Services)

In the `default` namespace, the SMS Checker consists of four Deployments and two Services.

#### Deployments

For canary releases, both the app and the model are deployed in two versions:

- `test-release-sms-checker-app-v1`
- `test-release-sms-checker-app-v2`
- `test-release-sms-checker-model-v1`
- `test-release-sms-checker-model-v2`

Each Deployment:

- runs a single replica (one pod per version),
- uses labels to identify the component and its version, e.g.:
  - `app.kubernetes.io/name: sms-checker`
  - `app.kubernetes.io/component: app` or `model`
  - `version: v1` or `version: v2`

Conceptually:

- **App v1/v2 pods** expose:
  - `GET /` – simple landing / health endpoint,
  - `POST /sms` – classification endpoint that forwards the SMS text to the model-service.
- **Model v1/v2 pods** expose:
  - `POST /predict` – prediction endpoint called by the app pods.

#### Services

Two ClusterIP Services provide stable network identities for the app and the model:

- **`test-release-sms-checker-app`** (ClusterIP)
  - Selects **both** app Deployments (`app-v1` and `app-v2`) via labels (component `app`).
  - Exposes **port 80**, mapped to **container port 8080** in the app pods.
  - Used as the destination by the Istio VirtualService for external traffic to the app.

- **`test-release-sms-checker-model`** (ClusterIP)
  - Selects **both** model Deployments (`model-v1` and `model-v2`) via labels (component `model`).
  - Exposes **port 80**, mapped to **container port 8081** in the model pods.
  - Used by the app pods via `MODEL_SERVICE_URL` / `MODEL_HOST` to reach the model-service.


### 2.3 Istio components and traffic management resources

Istio adds a service-mesh layer on top of the Kubernetes deployment. Structurally, the relevant parts are:

- **In `istio-system`**
  - `istiod` – the Istio control plane, which distributes configuration to Envoy proxies.
  - `istio-ingressgateway` – an Envoy-based IngressGateway exposed via a Service of type `LoadBalancer`. All external
    HTTP traffic for the SMS Checker enters the cluster through this gateway.

- **In `default`**
  - Envoy sidecars injected into each app and model pod (`app-v1`, `app-v2`, `model-v1`, `model-v2`), so that inbound
    and outbound HTTP traffic is processed according to Istio’s routing rules.
  - Istio configuration resources specific to this application:
    - a **Gateway** (`test-release-sms-checker-gateway`) that binds host `sms.local` on port 80 to the IngressGateway,
    - a **VirtualService** for the app (`test-release-sms-checker-app-vs`) that routes external traffic to the app
      Service and its v1/v2 subsets,
    - a **VirtualService** for the model (`test-release-sms-checker-model-vs`) that routes app → model calls to
      model v1/v2 subsets,
    - two **DestinationRules** (`…-app-dr` and `…-model-dr`) that define the logical subsets `v1` and `v2` for the
      app and model Services based on the `version` label.

The details of how these resources implement the 90/10 canary split and sticky sessions for “control” and “canary”
users are described in the **Data Flow** section.

## Data Flow

This section explains, at a high level, how requests move through the system and where dynamic routing decisions
are taken for the canary release and sticky sessions.

### 3.1 External request flow (client → app)

From a client’s perspective, every request goes to the same public entrypoint:

1. The client sends an HTTP request to the cluster via the **Istio IngressGateway** (host `sms.local`, port `80`).
2. The **Gateway** (`test-release-sms-checker-gateway`) matches this traffic for `sms.local` and passes it to the
   **app VirtualService** (`test-release-sms-checker-app-vs`).
3. The VirtualService forwards the request to the Kubernetes Service
   `test-release-sms-checker-app`, which then routes it to one of the app pods (v1 or v2).
4. The selected app pod:
   - serves `GET /` for a basic landing/health response, or
   - handles `POST /sms` and calls the model-service to obtain a prediction.

At this level, the important point is that **all external traffic** enters through the IngressGateway and is then
handed off to the app Service via Istio’s routing rules.

### 3.2 Experiment routing and sticky sessions (v1 vs v2)

The canary release and sticky sessions are implemented in the **app VirtualService**. Conceptually, it decides
**which version of the app** should handle each incoming request:

- Requests with header `x-doda-exp: control` are always routed to the **stable version (v1)**.
- Requests with header `x-doda-exp: canary` are always routed to the **canary version (v2)**.
- Requests **without** this header are split between v1 and v2 using a **weighted canary rollout**
  (e.g. around 90% to v1 and 10% to v2).

These rules map to logical “subsets” of the app behind the Service, defined in the app **DestinationRule**. This is
the main **dynamic routing decision point** for external traffic:

- It implements the global 90/10 canary split.
- It provides sticky behaviour for “control” and “canary” users based on a dedicated header.

### 3.3 App → model flow and consistent pairing

When the app needs a prediction, it calls the model-service through its Kubernetes Service
`test-release-sms-checker-model`. This internal call is also routed by Istio:

1. The request from the app pod goes to the model Service and is intercepted by the **model VirtualService**
   (`test-release-sms-checker-model-vs`).
2. The VirtualService uses information about the **calling app pod** (in particular its `version` label) and selects
   the matching subset of the model, defined in the model **DestinationRule**.

As a result:

- app v1 calls **model v1**,
- app v2 calls **model v2**,

so that each user consistently sees either the old pair (app+model v1) or the new pair (app+model v2). This is the
second **dynamic routing decision point**, ensuring consistency between the two services.

### 3.4 Overview

Putting it together, a typical request flows as:

> client → IngressGateway → Gateway → app VirtualService → app Service → app pod (v1 or v2)  
> → model VirtualService → model Service → model pod (v1 or v2) → back to client

The diagrams in this document show how these components are connected and where the two routing decisions
(90/10 split and app/model pairing) are applied.




## Monitoring

TO DO

## Extra Information
- Application configuration and credentials are provided via ConfigMaps and Secrets
