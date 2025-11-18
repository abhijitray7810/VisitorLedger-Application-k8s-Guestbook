#!/bin/bash

echo "Verifying Guestbook Application Deployment..."

echo "1. Checking Deployments:"
kubectl get deployments -l app=guestbook

echo ""
echo "2. Checking Services:"
kubectl get services -l app=guestbook

echo ""
echo "3. Checking Pods:"
kubectl get pods -l app=guestbook -o wide

echo ""
echo "4. Checking Pod Status:"
kubectl get pods -l app=guestbook -o jsonpath='{range .items[*]}{.metadata.name}: {.status.phase}{"\n"}{end}'

echo ""
echo "5. Checking Service Endpoints:"
kubectl get endpoints

echo ""
echo "6. Application URL:"
echo "The guestbook application should be accessible at: http://<node-ip>:30009"

echo ""
echo "Verification completed!"
