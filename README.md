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

### Operation (Current Repository)

These files define deployment and environment settings:

* **`docker-compose.yml`**: Orchestrates all services, networks, volumes, and dependencies.
* **`.env`**: Configures image tags, ports, and user IDs for volume permissions.
* **`models/`**: The mounted host directory used as a local cache for model files.

***

### App 

This component defines the Java application and its build process:

* **`Dockerfile`**: Defines the multi-stage build for the final container image.
* **`pom.xml`**: Manages dependencies and reuses the `lib-version` package.
* **`FrontendController.java`**: The core controller that processes user requests and calls the Model Service.
* **`release.yml`**: The CI/CD workflow for building and publishing the container image.

***

### Model Service 

This component manages the ML model and prediction API:

* **`Dockerfile`**: Defines the Python environment, dependencies, and container setup.
* **`entrypoint.sh`**: Startup script that checks the volume and downloads the model from a release if files are missing.
* **`serve_model.py`**: The main application that loads the model and exposes the prediction REST API.
* **`model-release.yml`**: The dedicated workflow for automating model training and release.
* **`requirements.txt`**: Lists all necessary Python packages (e.g., Flask, scikit-learn).