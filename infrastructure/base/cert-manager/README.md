# Cert-Manager Infrastructure

This directory contains the cert-manager configuration for automatic SSL/TLS certificate management.

## Overview

Cert-manager is a Kubernetes add-on that automates the management and issuance of TLS certificates from various issuing sources. It ensures certificates are valid and up to date, and attempts to renew certificates at an appropriate time before expiry.

## Components

### 1. Namespace
- **cert-manager**: Dedicated namespace for cert-manager components

### 2. Helm Chart
- **cert-manager**: Installed via Helm with security-focused configuration
- **Version**: v1.13.3 (latest stable)
- **CRDs**: Automatically installed

### 3. Cluster Issuers
- **letsencrypt-staging**: For testing certificates (no rate limits)
- **letsencrypt-prod**: For production certificates
- **selfsigned-issuer**: For internal/development certificates

### 4. Network Policies
- **cert-manager-network-policy**: Restricts network access for security

## Configuration Details

### Security Features
- **Non-root execution**: All pods run as non-root users (UID 1001)
- **Resource limits**: CPU and memory limits defined
- **Pod security**: Follows security best practices
- **Network isolation**: Restricted network access

### Resource Requirements
- **Requests**: 100m CPU, 128Mi memory
- **Limits**: 500m CPU, 512Mi memory
- **Replicas**: 1 (can be scaled based on needs)

## Usage

### Request a Certificate
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-app-tls
  namespace: my-app
spec:
  secretName: my-app-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - my-app.fellesdatakatalog.digdir.no
```

### Use in Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - my-app.fellesdatakatalog.digdir.no
      secretName: my-app-tls
```

## Deployment

CRDs are vendored in `crds.yaml` and must be re-fetched at the matching version
whenever the chart version changes:

```
curl -fsSL -o infrastructure/base/cert-manager/crds.yaml \
  https://github.com/cert-manager/cert-manager/releases/download/<version>/cert-manager.crds.yaml
```

Upgrade one minor version at a time, as upstream requires. After each step, check
that all Certificates stay `Ready` and that `notAfter`/`renewalTime` are unchanged,
so nothing is re-issued needlessly against Let's Encrypt rate limits.

Cert-manager is deployed via Flux CD:

- **Development**: `infrastructure/dev/cert-manager.yaml`
- **Production**: `infrastructure/prod/cert-manager.yaml`

## Monitoring

- **Health checks**: Available via cert-manager API
- **Metrics**: Prometheus metrics on port 9402
- **Logs**: Available via kubectl logs

## Troubleshooting

### Check cert-manager status
```bash
kubectl get pods -n cert-manager
kubectl get clusterissuers
kubectl get certificates -A
```

### Check certificate status
```bash
kubectl describe certificate my-app-tls -n my-app
kubectl describe order my-app-tls-order-123 -n my-app
```

### Check issuer status
```bash
kubectl describe clusterissuer letsencrypt-prod
```

## Let's Encrypt Rate Limits

- **Staging**: No rate limits, suitable for testing
- **Production**: 50 certificates per registered domain per week
- **Duplicate certificates**: 5 per week per domain

## Security Notes

- **Private keys**: Stored securely in Kubernetes secrets
- **ACME challenges**: HTTP-01 challenges via NGINX ingress
- **Email notifications**: Admin notifications for certificate issues
- **Automatic renewal**: Certificates auto-renew before expiry
