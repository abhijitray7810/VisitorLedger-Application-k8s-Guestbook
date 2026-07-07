# VisitorLedger-Application-k8s-Guestbook
# Nautilus Guestbook Application

## Overview

The Nautilus Guestbook Application is a cloud-native web application designed to manage guest/visitor entries. Built with a modern 3-tier architecture, it runs on Kubernetes and provides a scalable, reliable platform for capturing and displaying visitor messages.

## Architecture

The application follows a distributed architecture with clear separation between frontend and backend tiers:

### Backend Tier (Redis)
- **Redis Master**: Single instance handling all write operations
- **Redis Slave**: Two replicas handling read operations with automatic synchronization

### Frontend Tier
- **PHP Frontend**: Three replicas serving the web interface with load balancing

## Features

- ✍️ **Write Messages**: Visitors can submit guestbook entries
- 👀 **View Entries**: Display all submitted messages in real-time
- 🔄 **High Availability**: Multiple replicas ensure continuous operation
- ⚡ **Performance**: Separate read/write operations for optimal speed
- 📊 **Scalability**: Kubernetes-native design allows easy scaling

## Infrastructure Components

### Deployments

| Component | Replicas | Container Name | Image | Resources |
|-----------|----------|----------------|-------|-----------|
| redis-master | 1 | master-redis-xfusion | redis | CPU: 100m, Memory: 100Mi |
| redis-slave | 2 | slave-redis-xfusion | gcr.io/google_samples/gb-redisslave:v3 | CPU: 100m, Memory: 100Mi |
| frontend | 3 | php-redis-xfusion | gcr.io/google-samples/gb-frontend@sha256:a908df8... | CPU: 100m, Memory: 100Mi |

### Services

| Service | Type | Port | Target Port | Node Port |
|---------|------|------|-------------|-----------|
| redis-master | ClusterIP | 6379 | 6379 | - |
| redis-slave | ClusterIP | 6379 | 6379 | - |
| frontend | NodePort | 80 | 80 | 30009 |

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured to communicate with your cluster
- Access to jump_host with kubectl utility

## Installation

### Step 1: Clone or Download the Deployment File

Save the Kubernetes manifest as `guestbook-deployment.yaml`

### Step 2: Deploy to Kubernetes

```bash
# Apply all resources
kubectl apply -f guestbook-deployment.yaml
```

### Step 3: Verify Deployment

```bash
# Check deployment status
kubectl get deployments

# Expected output:
# NAME           READY   UP-TO-DATE   AVAILABLE   AGE
# redis-master   1/1     1            1           1m
# redis-slave    2/2     2            2           1m
# frontend       3/3     3            3           1m

# Check pods
kubectl get pods

# Check services
kubectl get services

# Expected output should show:
# NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# redis-master   ClusterIP   10.96.x.x       <none>        6379/TCP       1m
# redis-slave    ClusterIP   10.96.x.x       <none>        6379/TCP       1m
# frontend       NodePort    10.96.x.x       <none>        80:30009/TCP   1m
```

### Step 4: Access the Application

The guestbook application is accessible via:

- **Browser**: `http://<node-ip>:30009`
- **App Button**: Click the App button in your environment

Replace `<node-ip>` with any node's IP address in your Kubernetes cluster.

## Usage

1. **Navigate** to the application URL
2. **Enter** your message in the text field
3. **Submit** to add your entry to the guestbook
4. **View** all entries displayed on the page

## Application Flow

```
User Browser
     ↓
Frontend Service (NodePort :30009)
     ↓
Frontend Pods (3 replicas)
     ↓
├─→ Redis Master (writes) ←─┐
│                            │
└─→ Redis Slave (reads) ←────┘
         (sync)
```

**Write Operation**: User submits message → Frontend → Redis Master → Data stored

**Read Operation**: Page loads → Frontend → Redis Slave → Messages displayed

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| GET_HOSTS_FROM | dns | Enables Kubernetes DNS-based service discovery |

## Resource Limits

All containers are configured with:
- **CPU Request**: 100m (0.1 CPU core)
- **Memory Request**: 100Mi

## Scaling

### Scale Frontend

```bash
# Increase frontend replicas
kubectl scale deployment frontend --replicas=5

# Decrease frontend replicas
kubectl scale deployment frontend --replicas=2
```

### Scale Redis Slaves

```bash
# Add more read replicas
kubectl scale deployment redis-slave --replicas=4
```

**Note**: Redis Master should remain at 1 replica for data consistency.

## Monitoring

```bash
# View logs from frontend
kubectl logs -l app=guestbook,tier=frontend

# View logs from redis master
kubectl logs -l app=redis,role=master

# View logs from redis slave
kubectl logs -l app=redis,role=slave

# Describe a specific pod
kubectl describe pod <pod-name>
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe problematic pod
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Application Not Accessible

```bash
# Verify service
kubectl get svc frontend

# Check if pods are ready
kubectl get pods -l app=guestbook

# Test from within cluster
kubectl run test-pod --rm -i --tty --image=busybox -- sh
wget -O- frontend.default.svc.cluster.local
```

### Redis Connection Issues

```bash
# Check redis-master service
kubectl get svc redis-master

# Check redis-slave service
kubectl get svc redis-slave

# Test redis connection
kubectl run redis-test --rm -i --tty --image=redis -- redis-cli -h redis-master ping
```

## Cleanup

To remove the guestbook application:

```bash
# Delete all resources
kubectl delete -f guestbook-deployment.yaml

# Verify deletion
kubectl get deployments
kubectl get services
kubectl get pods
```

## Labels Used

### Backend Tier
- `app: redis`
- `role: master` / `role: slave`
- `tier: backend`

### Frontend Tier
- `app: guestbook`
- `tier: frontend`

## Security Considerations

- Redis instances are only accessible within the cluster (ClusterIP)
- Frontend is exposed via NodePort (30009) for external access
- No authentication configured (suitable for development/demo)
- For production: Consider adding Redis authentication, network policies, and TLS

## Technical Stack

- **Frontend**: PHP with Redis client
- **Backend**: Redis (Master-Slave replication)
- **Orchestration**: Kubernetes
- **Service Discovery**: Kubernetes DNS

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Kubernetes cluster logs
3. Contact the Nautilus DevOps team

## License

Internal Nautilus project - All rights reserved

## Version History

- **v1.0.0** - Initial deployment with 3-tier architecture
  - Redis Master/Slave setup
  - Frontend with 3 replicas
  - NodePort service on port 30009

---

**Maintained by**: Nautilus Application Development Team  
**Last Updated**: November 2025
