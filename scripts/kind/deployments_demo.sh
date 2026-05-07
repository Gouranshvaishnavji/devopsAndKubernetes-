#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../" && pwd)"
cd "$ROOT"

echo "Applying Deployment"
kubectl apply -f k8s/backend-deployment.yaml
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get deployment pdf-extractor-backend -o wide
kubectl get pods -l app=pdf-extractor-backend -o wide

echo "Performing rolling update: set image to nginx:1.24-alpine"
kubectl set image deployment/pdf-extractor-backend backend=nginx:1.24-alpine --record
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get pods -l app=pdf-extractor-backend -o wide
kubectl rollout history deployment/pdf-extractor-backend

echo "Undoing rollout to previous revision"
kubectl rollout undo deployment/pdf-extractor-backend
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get pods -l app=pdf-extractor-backend -o wide

echo "Demo finished"
