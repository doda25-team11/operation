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


## Monitoring

TO DO

## Extra Information
- Application configuration and credentials are provided via ConfigMaps and Secrets
