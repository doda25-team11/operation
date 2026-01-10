# SMS Checker – Deployment Documentation

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
## Data Flow
## Monitoring
## Extra Information