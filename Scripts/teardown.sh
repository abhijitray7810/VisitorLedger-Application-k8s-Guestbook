#!/bin/bash

echo "Tearing down Guestbook Application..."

echo "Deleting frontend components..."
kubectl delete -f k8s-manifests/frontend/

echo "Deleting backend components..."
kubectl delete -f k8s-manifests/backend/

echo "Checking if all resources are deleted..."
kubectl get deployments
kubectl get services
kubectl get pods

echo "Teardown completed!"
