# Kubernetes Deployment Guide - Phase F

This guide will help you deploy the Piazza API to Google Kubernetes Engine (GKE) with 5 replicas and a LoadBalancer.

## Prerequisites

✅ GKE cluster created (you've already done this!)
✅ `kubectl` installed on your machine
✅ Docker image pushed to Docker Hub: `fmacayasecurity/piazza-api:latest`

---

## Step 1: Connect to Your GKE Cluster

```bash
# Get credentials for your cluster
gcloud container clusters get-credentials piazza-cluster --zone=us-central1-a

# Verify connection - should show 3 nodes
kubectl get nodes
```

**Expected output:**
```
NAME                                          STATUS   ROLES    AGE   VERSION
gke-piazza-cluster-default-pool-xxxxx-1234    Ready    <none>   5m    v1.27.x
gke-piazza-cluster-default-pool-xxxxx-5678    Ready    <none>   5m    v1.27.x
gke-piazza-cluster-default-pool-xxxxx-9012    Ready    <none>   5m    v1.27.x
```

---

## Step 2: Create Kubernetes Secret (Sensitive Data)

**IMPORTANT:** Replace the values with your actual credentials!

```bash
# Create secret with your MongoDB URI and JWT Secret
kubectl create secret generic piazza-secrets \
  --from-literal=MONGODB_URI='mongodb+srv://your-user:your-password@cluster.mongodb.net/piazza?retryWrites=true&w=majority' \
  --from-literal=JWT_SECRET='your-super-secret-jwt-key-here'

# Verify secret was created
kubectl get secrets
```

---

## Step 3: Deploy to Kubernetes

Navigate to the backend directory and apply all manifests:

```bash
# Go to backend directory
cd cam-backend

# Apply all Kubernetes manifests
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Or apply all at once:
kubectl apply -f kubernetes/
```

**Expected output:**
```
configmap/piazza-config created
deployment.apps/piazza-api-deployment created
service/piazza-api-service created
```

---

## Step 4: Check Deployment Status

```bash
# Check if pods are running (should see 5 pods)
kubectl get pods

# Watch pods until all are Running
kubectl get pods -w

# Check deployment
kubectl get deployment piazza-api-deployment

# Check service
kubectl get service piazza-api-service
```

**Expected output for pods:**
```
NAME                                     READY   STATUS    RESTARTS   AGE
piazza-api-deployment-xxxxxxxxx-abcde    1/1     Running   0          2m
piazza-api-deployment-xxxxxxxxx-fghij    1/1     Running   0          2m
piazza-api-deployment-xxxxxxxxx-klmno    1/1     Running   0          2m
piazza-api-deployment-xxxxxxxxx-pqrst    1/1     Running   0          2m
piazza-api-deployment-xxxxxxxxx-uvwxy    1/1     Running   0          2m
```

---

## Step 5: Get LoadBalancer External IP

```bash
# Get service details
kubectl get service piazza-api-service

# Watch until EXTERNAL-IP changes from <pending> to an actual IP
kubectl get service piazza-api-service -w
```

**This may take 2-5 minutes!**

**Expected output:**
```
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
piazza-api-service   LoadBalancer   10.xx.xxx.xxx   34.123.45.67     80:30123/TCP   3m
```

**Your LoadBalancer IP is:** `34.123.45.67` (example)

---

## Step 6: Test Your API

Once you have the EXTERNAL-IP:

```bash
# Test health endpoint
curl http://YOUR_EXTERNAL_IP/api/health

# Test full API
curl http://YOUR_EXTERNAL_IP/api/posts
```

**Expected response:**
```json
{
  "success": true,
  "message": "Server is healthy"
}
```

---

## Step 7: Update Frontend to Use LoadBalancer

Update your frontend's `api.js`:

```javascript
const API_BASE_URL = 'http://YOUR_EXTERNAL_IP/api';
```

---

## Useful Commands

### View Logs
```bash
# Get logs from all pods
kubectl logs -l app=piazza-api

# Get logs from specific pod
kubectl logs piazza-api-deployment-xxxxxxxxx-abcde

# Follow logs in real-time
kubectl logs -f piazza-api-deployment-xxxxxxxxx-abcde
```

### Describe Resources
```bash
# Detailed info about deployment
kubectl describe deployment piazza-api-deployment

# Detailed info about service
kubectl describe service piazza-api-service

# Detailed info about a pod
kubectl describe pod piazza-api-deployment-xxxxxxxxx-abcde
```

### Scale Replicas (Optional)
```bash
# Scale to 10 replicas
kubectl scale deployment piazza-api-deployment --replicas=10

# Scale back to 5
kubectl scale deployment piazza-api-deployment --replicas=5
```

### Update Docker Image
```bash
# After pushing new image to Docker Hub
kubectl rollout restart deployment piazza-api-deployment

# Check rollout status
kubectl rollout status deployment piazza-api-deployment
```

### Delete Everything
```bash
# Delete all resources
kubectl delete -f kubernetes/

# Or delete individually
kubectl delete deployment piazza-api-deployment
kubectl delete service piazza-api-service
kubectl delete configmap piazza-config
kubectl delete secret piazza-secrets
```

---

## Troubleshooting

### Pods not starting?
```bash
# Check pod events
kubectl describe pod piazza-api-deployment-xxxxxxxxx-abcde

# Check logs
kubectl logs piazza-api-deployment-xxxxxxxxx-abcde
```

### LoadBalancer stuck on <pending>?
- Wait 5 minutes (it takes time to provision)
- Check GCP quotas: https://console.cloud.google.com/iam-admin/quotas
- Verify billing is enabled

### Can't connect to API?
```bash
# Check if service is running
kubectl get service piazza-api-service

# Check firewall rules in GCP
# Make sure port 80 is open

# Test from inside a pod
kubectl run test --image=curlimages/curl -it --rm -- sh
curl http://piazza-api-service/api/health
```

### Secret not found error?
```bash
# Verify secret exists
kubectl get secrets

# Recreate secret
kubectl delete secret piazza-secrets
kubectl create secret generic piazza-secrets \
  --from-literal=MONGODB_URI='your-uri' \
  --from-literal=JWT_SECRET='your-secret'
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Google Cloud                        │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │         LoadBalancer (External IP)         │    │
│  │         http://34.123.45.67               │    │
│  └─────────────────┬──────────────────────────┘    │
│                    │                                │
│         ┌──────────┴──────────┐                    │
│         │  Kubernetes Service │                    │
│         │  (piazza-api-service)│                   │
│         └──────────┬──────────┘                    │
│                    │                                │
│    ┌───────┬───────┼───────┬───────┬──────┐       │
│    │       │       │       │       │      │       │
│  ┌─▼─┐  ┌─▼─┐  ┌─▼─┐  ┌─▼─┐  ┌─▼─┐           │
│  │Pod│  │Pod│  │Pod│  │Pod│  │Pod│  5 Replicas │
│  │ 1 │  │ 2 │  │ 3 │  │ 4 │  │ 5 │              │
│  └───┘  └───┘  └───┘  └───┘  └───┘              │
│                                                      │
│  Each pod runs: fmacayasecurity/piazza-api:latest  │
└─────────────────────────────────────────────────────┘
```

---

## Cost Management

**To save costs after testing:**

```bash
# Scale down to 1 replica
kubectl scale deployment piazza-api-deployment --replicas=1

# Or delete everything
kubectl delete -f kubernetes/

# Delete the cluster (saves the most)
gcloud container clusters delete piazza-cluster --zone=us-central1-a
```

---

## Phase F Checklist

- ✅ Created Kubernetes cluster on GCP
- ✅ Deployed application with 5 replicas
- ✅ Created LoadBalancer service
- ✅ Obtained external IP address
- ✅ Tested API endpoints
- ✅ Documented deployment process

**Your LoadBalancer IP:** `_________________` (fill this in!)

---

## Support

If you encounter issues:
1. Check pod logs: `kubectl logs -l app=piazza-api`
2. Check pod status: `kubectl get pods`
3. Verify secrets: `kubectl get secrets`
4. Check GCP console for any quota/billing issues

Good luck with Phase F! 🚀
