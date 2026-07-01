House Price Predictor – MLOps on AKS

This project shows how to build and deploy a machine learning application on Azure Kubernetes Service (AKS) using MLOps, Terraform, GitHub Actions, Argo CD, Azure Container Registry, Prometheus, and Grafana.

The application predicts house prices using a trained ML model. It includes a FastAPI backend and a Streamlit UI.

Project Flow
Data Processing
      ↓
Model Training
      ↓
Docker Build and Push to ACR
      ↓
AKS Deployment using Terraform
      ↓
Argo CD GitOps Deployment
      ↓
Monitoring with Prometheus and Grafana
Main Components
Component	Purpose
Python	Data processing and model training
FastAPI	Serves the ML model as an API
Streamlit	Web UI for users
Docker	Packages the application
Azure Container Registry	Stores Docker images
AKS	Runs the application containers
Terraform	Creates and manages AKS infrastructure
GitHub Actions	Automates build and deployment
Argo CD	Deploys Kubernetes manifests using GitOps
Prometheus / Grafana	Monitoring and dashboards
Azure Resources
Resource Group: lab2026
AKS Cluster: ai-workload
ACR Name: labopsACR2025
ACR Login Server: labopsacr2025.azurecr.io

Docker images:

labopsacr2025.azurecr.io/house-price-model:latest
labopsacr2025.azurecr.io/house-price-streamlit:latest
Repository Structure
house-price-predictor/
├── data/                  # Raw and processed data
├── notebooks/             # ML notebooks
├── src/                   # Python source code
│   ├── api/               # FastAPI app
│   ├── data/              # Data processing
│   ├── features/          # Feature engineering
│   └── models/            # Model training
├── streamlit_app/         # Streamlit UI
├── deployment/
│   ├── kubernetes/        # App Kubernetes manifests
│   ├── monitoring/        # Monitoring manifests
│   └── mlflow/            # MLflow local setup
├── terraform/             # AKS and Argo CD infrastructure
├── Dockerfile             # FastAPI image
└── README.md
Run Locally

Create virtual environment:

python -m venv .venv
source .venv/bin/activate

Install dependencies:

pip install -r requirements.txt

Run FastAPI:

uvicorn src.api.main:app --host 0.0.0.0 --port 8000

Test API:

curl http://localhost:8000/health

Run Streamlit:

cd streamlit_app
streamlit run app.py

Open:

http://localhost:8501
Build Docker Images

FastAPI image:

docker build -t house-price-model:local .

Streamlit image:

docker build -t house-price-streamlit:local ./streamlit_app
GitHub Actions Pipeline

The pipeline runs automatically on push to main.

Main jobs:

data-processing
model-training
Docker_build-and-publish_ACR
Deploy_to_AKS_with_Terraform
argocd-deploy

The pipeline:

Processes data
Trains the model
Builds Docker images
Pushes images to ACR
Deploys AKS using Terraform
Installs Argo CD
Deploys FastAPI, Streamlit, Prometheus, and Grafana
Terraform

Terraform is used to manage:

AKS cluster
Node pools
ACR pull permission
Cluster autoscaler
Argo CD installation
Argo CD application bootstrap

Run locally:

cd terraform
terraform init -backend=false -upgrade
terraform fmt
terraform validate
Argo CD

Argo CD deploys the application from GitHub to AKS.

Check Argo CD:

kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl get applications -n argocd

Get Argo CD password:

kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d; echo

Access Argo CD:

http://<argocd-external-ip>

Login:

Username: admin
Password: <password from command>
Application Access

Check pods:

kubectl get pods -n default

Check services:

kubectl get svc -n default

Access Streamlit:

kubectl get svc streamlit -n default

Open:

http://<streamlit-external-ip>
Monitoring

Prometheus and Grafana are deployed for monitoring.

Check monitoring:

kubectl get pods -n monitoring
kubectl get svc -n monitoring

Access Grafana:

kubectl get svc -n monitoring

Open:

http://<grafana-external-ip>

Default login:

Username: admin
Password: password-here
Troubleshooting
ImagePullBackOff

Check pod details:

kubectl describe pod <pod-name> -n default

Verify ACR images:

az acr repository list --name labopsACR2025 -o table

Expected repositories:

house-price-model
house-price-streamlit
Argo CD Sync Issue
kubectl get applications -n argocd
kubectl describe application <application-name> -n argocd
Check Autoscaling
kubectl get hpa -A
kubectl get vpa -A
kubectl get scaledobject -A
kubectl get nodes
Project Goal

The goal of this project is to demonstrate a simple, practical MLOps workflow on Azure:

ML model → Docker image → ACR → AKS → Argo CD → Monitoring

This project is useful for learning how cloud, DevOps, Kubernetes, and MLOps work together in a real deployment workflow.