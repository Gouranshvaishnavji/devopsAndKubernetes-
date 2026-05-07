Param()

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $root

Write-Output "Applying Deployment"
kubectl apply -f k8s/backend-deployment.yaml | Out-Null
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get deployment pdf-extractor-backend -o wide
kubectl get pods -l app=pdf-extractor-backend -o wide

Write-Output "Performing rolling update: set image to nginx:1.24-alpine"
kubectl set image deployment/pdf-extractor-backend backend=nginx:1.24-alpine --record
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get pods -l app=pdf-extractor-backend -o wide
kubectl rollout history deployment/pdf-extractor-backend

Write-Output "Undoing rollout to previous revision"
kubectl rollout undo deployment/pdf-extractor-backend
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get pods -l app=pdf-extractor-backend -o wide

Write-Output "Demo finished"
