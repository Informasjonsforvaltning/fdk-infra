# Keycloak HA Cluster Configuration

This directory contains the Keycloak HA cluster configuration for different environments.

## Overview

This directory contains the base configuration for Keycloak HA clusters deployed across different environments:

- **Staging** (`apps/dev/keycloak-staging/`): 1 instance, minimal resources
- **Demo** (`apps/dev/keycloak-demo/`): 2 instances, moderate resources

### Production Environment

- **Production** (`apps/prod/keycloak/`): 3 instances, high resources

## Environment-Specific Configurations

### **Staging Environment** (`apps/dev/keycloak-staging/`)

- **Domain**: `auth.staging.fellesdatakatalog.digdir.no`
- **Admin Domain**: `auth.staging.fellesdatakatalog.digdir.no`
- **Instances**: 1
- **Resources**: 200m-500m CPU, 256Mi-1Gi memory
- **Database**: External PostgreSQL via secrets
- **TLS**: Let's Encrypt (production server)

### **Demo Environment** (`apps/dev/keycloak-demo/`)

- **Domain**: `auth.demo.fellesdatakatalog.digdir.no`
- **Admin Domain**: `auth.demo.fellesdatakatalog.digdir.no`
- **Instances**: 2
- **Resources**: 250m-1 CPU, 512Mi-2Gi memory
- **Database**: External PostgreSQL via secrets
- **TLS**: Let's Encrypt (production server)

### **Production Environment** (`apps/prod/keycloak/`)

- **Domain**: `auth.fellesdatakatalog.digdir.no`
- **Admin Domain**: `auth.fellesdatakatalog.digdir.no`
- **Instances**: 3
- **Resources**: 1000m-4 CPU, 2Gi-8Gi memory
- **Database**: External PostgreSQL via secrets
- **TLS**: Let's Encrypt (production server)

## Configuration Structure

Each environment follows this structure:

```
environment/
├── kustomization.yaml      # Kustomize configuration
├── keycloak-patch.yaml     # Environment-specific Keycloak configuration
└── certificate-patch.yaml  # Environment-specific certificate configuration
```

### Configuration Details

#### Keycloak Instances

- **Staging**: 1 instance, 200m-500m CPU, 256Mi-1Gi memory
- **Demo**: 2 instances, 250m-1 CPU, 512Mi-2Gi memory
- **Production**: 3 instances, 1000m-4 CPU, 2Gi-8Gi memory

#### Database

- External PostgreSQL database accessed via additionalOptions
- Database configuration managed externally via secret management
- Separate database per environment

#### Security Features

- TLS encryption enabled
- Non-root container execution
- Resource limits and requests
- Health checks and probes
- **Metrics enabled** (`KC_METRICS_ENABLED: true) but cluster-internal only
- **Monitoring endpoints cluster-internal only** (not exposed via ingress)

## TLS Configuration

Keycloak is configured with **dual TLS layers** using cert-manager for both:

### **1. External TLS (Ingress Level)**

- **Port 443**: HTTPS access from internet
- **Certificate**: Managed by cert-manager via ClusterIssuers
- **Issuers per environment**:
  - **Staging**: `letsencrypt-dev` (Let's Encrypt production server - internet-facing)
  - **Demo**: `letsencrypt-dev` (Let's Encrypt production server - internet-facing)
  - **Production**: `letsencrypt-prod` (Let's Encrypt production server)

### **2. Internal TLS (Pod Level)**

- **Port 8443**: HTTPS communication between ingress and Keycloak pods
- **Certificate**: `keycloak-internal-tls` managed by cert-manager
- **Same issuers** as external TLS for consistency
- **Benefits**: End-to-end encryption, no plain HTTP in cluster

## Prerequisites

1. **Keycloak Operator**: Must be deployed in infrastructure first
2. **External Database**: PostgreSQL database must be accessible
3. **TLS Certificates**: Valid certificates for ingress
4. **External Secrets**: Database credentials managed via external secret management

## Deployment

The Keycloak clusters are deployed via Flux CD:

```bash
# Staging
flux create kustomization keycloak-staging --source=flux-system --path=./apps/dev/keycloak-staging

# Demo
flux create kustomization keycloak-demo --source=flux-system --path=./apps/dev/keycloak-demo

# Production
flux create kustomization keycloak --source=flux-system --path=./apps/prod/keycloak
```

## Access URLs

- **Staging**: https://auth.staging.fellesdatakatalog.digdir.no
- **Demo**: https://auth.demo.fellesdatakatalog.digdir.no
- **Production**: https://auth.fellesdatakatalog.digdir.no

## Monitoring

- Health checks: `/health/ready`
- Metrics: `/metrics` (enabled, cluster-internal only)
- Logs: Available via kubectl logs (cluster-internal access only)
- **Security Note**: Sensitive endpoints (/metrics, /admin, /realms/master/protocol/openid-connect/userinfo) are explicitly blocked at the ingress level with NGINX server-snippet

## Troubleshooting

1. Check operator status: `kubectl get keycloaks -A`
2. Check database connectivity: Verify external database connectivity from Keycloak logs
3. Check Keycloak logs: `kubectl logs -l app=keycloak`
4. Verify TLS certificates: `kubectl get secret keycloak-internal-tls -n <namespace>`
5. Check ingress certificates: `kubectl get certificate -A`
