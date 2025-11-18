#!/bin/bash

echo "Deploying Guestbook Application..."

echo "Creating backend components..."
kubectl apply -f k8s-manifests/backend/

echo "Creating frontend components..."
kubectl apply -f k8s-manifests/frontend/

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=guestbook --timeout=300s

echo "Deployment completed!"
echo ""
echo "Checking resources:"
kubectl get deployments
echo ""
kubectl get services
echo ""
kubectl get pods -o wide
