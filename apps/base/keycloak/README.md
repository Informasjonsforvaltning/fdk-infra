# Keycloak HA Cluster Configuration

This directory contains the Keycloak HA cluster configuration for different environments.

## Overview

This directory contains the base configuration for Keycloak HA clusters deployed across different environments:

- **Staging** (`apps/dev/keycloak-staging/`): 3 instances, minimal resources
- **Demo** (`apps/dev/keycloak-demo/`): 3 instances, minimal resources

### Production Environment

- **Production** (`apps/prod/keycloak/`): 3 instances, high resources

## Environment-Specific Configurations

### **Staging Environment** (`apps/dev/keycloak-staging/`)

- **Domain**: `auth.staging.fellesdatakatalog.digdir.no`
- **Admin Domain**: `auth.staging.fellesdatakatalog.digdir.no`
- **Instances**: 3
- **Resources**: 200m-500m CPU, 256Mi-1Gi memory
- **Database**: External PostgreSQL via secrets
- **TLS**: Internal CA between the Gateway and Keycloak

### **Demo Environment** (`apps/dev/keycloak-demo/`)

- **Domain**: `auth.demo.fellesdatakatalog.digdir.no`
- **Admin Domain**: `auth.demo.fellesdatakatalog.digdir.no`
- **Instances**: 3
- **Resources**: 200m-500m CPU, 256Mi-1Gi memory
- **Database**: External PostgreSQL via secrets
- **TLS**: Internal CA between the Gateway and Keycloak

### **Production Environment** (`apps/prod/keycloak/`)

- **Domain**: `auth.fellesdatakatalog.digdir.no`
- **Admin Domain**: `auth.fellesdatakatalog.digdir.no`
- **Instances**: 3
- **Resources**: 1000m-4 CPU, 2Gi-8Gi memory
- **Database**: External PostgreSQL via secrets
- **TLS**: Let's Encrypt between ingress-nginx and Keycloak

## Configuration Structure

Each environment follows this structure:

```
environment/
├── kustomization.yaml      # Kustomize configuration
├── keycloak.yaml           # Keycloak custom resource for the environment
└── certificate-patch.yaml  # Environment-specific certificate configuration
```

### Configuration Details

#### Keycloak Instances

- **Staging**: 3 instances, 200m-500m CPU, 256Mi-1Gi memory
- **Demo**: 3 instances, 200m-500m CPU, 256Mi-1Gi memory
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
- **Monitoring endpoints cluster-internal only** (not exposed publicly)

## TLS Configuration

Keycloak is configured with **two TLS layers**:

### **1. External TLS (Load Balancer Level)**

- **Port 443**: HTTPS access from internet, terminated at the Google load balancer
- **Staging** and **Demo**: the certificates on the `staging-edge` Gateway (`apps/dev/gateway-staging/`)
- **Production**: the certificate on the production Ingress (`infrastructure/prod/ingress/`)

### **2. Internal TLS (Pod Level)**

- **Port 8443**: HTTPS from the Gateway (Staging and Demo) or ingress-nginx (Production) to the Keycloak pods
- **Certificate**: `keycloak-internal-tls` managed by cert-manager
- **Issuers per environment**:
  - **Staging** and **Demo**: `internal-ca`, which the Gateway trusts through its BackendTLSPolicy
  - **Production**: `letsencrypt-prod`

## Prerequisites

1. **Keycloak Operator**: Must be deployed in infrastructure first
2. **External Database**: PostgreSQL database must be accessible
3. **TLS Certificates**: cert-manager with the issuers listed above
4. **External Secrets**: Database credentials managed via external secret management

## Deployment

Flux deploys each environment through its Kustomization, which depends on the Keycloak operator for that environment:

- **Staging**: `apps/dev/keycloak-staging.yaml`
- **Demo**: `apps/dev/keycloak-demo.yaml`
- **Production**: `apps/prod/keycloak.yaml`

## Access URLs

- **Staging**: https://auth.staging.fellesdatakatalog.digdir.no
- **Demo**: https://auth.demo.fellesdatakatalog.digdir.no
- **Production**: https://auth.fellesdatakatalog.digdir.no

## Monitoring

- Health checks: `/health/ready`
- Logs: Available via kubectl logs (cluster-internal access only)
- **Security Note**: `/metrics` and the master realm's userinfo endpoint are blocked before they reach Keycloak

## Troubleshooting

1. Check operator status: `kubectl get keycloaks -A`
2. Check database connectivity: Verify external database connectivity from Keycloak logs
3. Check Keycloak logs: `kubectl logs -l app=keycloak -n <namespace>`
4. Verify TLS certificates: `kubectl get secret keycloak-internal-tls -n <namespace>`
5. Check certificates: `kubectl get certificate -n <namespace>`
