#!/bin/bash
# Script to import existing production infrastructure into Terraform state
# Run this from the terraform/prod directory after configuring terraform.tfvars
# Usage: ./import-resources.sh

set -e

PROJECT_ID="digdir-fdk-prod"
REGION="europe-north1"
ZONE="europe-north1-a"

echo "=========================================="
echo "Starting Terraform import process for production infrastructure"
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "=========================================="
echo ""

# Function to safely import (skip if already in state)
safe_import() {
    local resource=$1
    local id=$2
    echo "Importing: $resource"
    if terraform state show "$resource" >/dev/null 2>&1; then
        echo "  ⏭️  Already in state, skipping..."
    else
        terraform import "$resource" "$id" || echo "  ⚠️  Failed to import $resource"
    fi
    echo ""
}

# ==========================================
# 1. API Services
# ==========================================
echo "📦 Importing API Services..."
safe_import "google_project_service.compute" "$PROJECT_ID/compute.googleapis.com"
safe_import "google_project_service.container" "$PROJECT_ID/container.googleapis.com"
safe_import "google_project_service.iam" "$PROJECT_ID/iam.googleapis.com"
safe_import "google_project_service.sqladmin" "$PROJECT_ID/sqladmin.googleapis.com"
safe_import "google_project_service.storage" "$PROJECT_ID/storage-api.googleapis.com"
safe_import "google_project_service.cloudresourcemanager" "$PROJECT_ID/cloudresourcemanager.googleapis.com"
safe_import "google_project_service.servicenetworking" "$PROJECT_ID/servicenetworking.googleapis.com"
safe_import "google_project_service.secretmanager" "$PROJECT_ID/secretmanager.googleapis.com"
safe_import "google_project_service.iamcredentials" "$PROJECT_ID/iamcredentials.googleapis.com"
safe_import "google_project_service.cloudfunctions" "$PROJECT_ID/cloudfunctions.googleapis.com"
safe_import "google_project_service.cloudbuild" "$PROJECT_ID/cloudbuild.googleapis.com"
safe_import "google_project_service.artifactregistry" "$PROJECT_ID/artifactregistry.googleapis.com"

# ==========================================
# 2. Service Accounts (Compute)
# ==========================================
echo "👤 Importing Compute Service Accounts..."
# Note: Replace <email> with actual service account emails from your environment
# You can get these with: gcloud iam service-accounts list

echo "⚠️  TODO: Update service account emails in this script"
echo "    Run: gcloud iam service-accounts list --format='value(email)'"
echo ""

# Example (uncomment and update with actual emails):
safe_import "google_service_account.cloud_sql_proxy" "projects/$PROJECT_ID/serviceAccounts/digdir-fdk-prod-cloudsql@$PROJECT_ID.iam.gserviceaccount.com"
safe_import "google_service_account.vertex_ai" "projects/$PROJECT_ID/serviceAccounts/digdir-fdk-prod-vertex-sa@$PROJECT_ID.iam.gserviceaccount.com"
safe_import "google_service_account.error_reporting" "projects/$PROJECT_ID/serviceAccounts/digdir-fdk-prod-error-sa@$PROJECT_ID.iam.gserviceaccount.com"


# ==========================================
# 3. Service Accounts (Storage)
# ==========================================
echo "💾 Importing Storage Service Accounts..."
safe_import "google_service_account.bucket" "projects/$PROJECT_ID/serviceAccounts/digdir-fdk-prod-bucket-sa@$PROJECT_ID.iam.gserviceaccount.com"

# ==========================================
# 4. Workload Identity Federation
# ==========================================
echo "🔐 Importing Workload Identity Federation..."
# Get pool and provider names from: gcloud iam workload-identity-pools list --location=global

echo "⚠️  TODO: Update workload identity pool and provider names"
echo "    Run: gcloud iam workload-identity-pools list --location=global"
echo ""

POOL_NAME="github-actions"
PROVIDER_NAME="github"
safe_import "google_iam_workload_identity_pool.github" "projects/$PROJECT_ID/locations/global/workloadIdentityPools/$POOL_NAME"
safe_import "google_iam_workload_identity_pool_provider.github" "projects/$PROJECT_ID/locations/global/workloadIdentityPools/$POOL_NAME/providers/$PROVIDER_NAME"

# ==========================================
# 5. Global IP Addresses
# ==========================================
echo "🌐 Importing Global IP Addresses..."
# Get address names from: gcloud compute addresses list --global

echo "⚠️  TODO: Update global address names"
echo "    Run: gcloud compute addresses list --global --format='value(name)'"
echo ""

# Example (uncomment and update):
safe_import "google_compute_global_address.prod_v4" "projects/$PROJECT_ID/global/addresses/digdir-fdk-prod-v4"
safe_import "google_compute_global_address.prod_v6" "projects/$PROJECT_ID/global/addresses/digdir-fdk-prod-v6"

# ==========================================
# 6. Cloud Armor Policies
# ==========================================
echo "🛡️  Importing Cloud Armor Policies..."
safe_import "google_compute_security_policy.admin" "digdir-fdk-cloud-armor-policy-admin"
safe_import "google_compute_security_policy.bff" "digdir-fdk-cloud-armor-policy-bff"
safe_import "google_compute_security_policy.datalandsbyen" "digdir-fdk-cloud-armor-policy-datalandsbyen"
safe_import "google_compute_security_policy.harvesters" "digdir-fdk-cloud-armor-policy-harvesters"
safe_import "google_compute_security_policy.publishers" "digdir-fdk-cloud-armor-policy-publishers"
safe_import "google_compute_security_policy.registration" "digdir-fdk-cloud-armor-policy-registration"
safe_import "google_compute_security_policy.search" "digdir-fdk-cloud-armor-policy-search"
safe_import "google_compute_security_policy.services" "digdir-fdk-cloud-armor-policy-services"
safe_import "google_compute_security_policy.sparql" "digdir-fdk-cloud-armor-policy-sparql"
safe_import "google_compute_security_policy.validator" "digdir-fdk-cloud-armor-policy-validator"
safe_import "google_compute_security_policy.nginx_controller" "digdir-fdk-prod-cloud-armor-nginx-controller"

# ==========================================
# 7. Storage Buckets
# ==========================================
echo "🪣 Importing Storage Buckets..."
# Get bucket names from: gcloud storage buckets list

echo "⚠️  TODO: Update storage bucket names"
echo "    Run: gcloud storage buckets list --format='value(name)'"
echo ""

# Example (uncomment and update):
safe_import "google_storage_bucket.metrics" "digdir-fdk-prod-terraform-state"
safe_import "google_storage_bucket.cloud_functions_uploads" "thanos-long-term-metric-storage"

# ==========================================
# 8. PostgreSQL Database
# ==========================================
echo "🗄️  Importing Cloud SQL Instance..."
# Get instance name from: gcloud sql instances list

echo "⚠️  TODO: Update Cloud SQL instance name"
echo "    Run: gcloud sql instances list --format='value(name)'"
echo ""

# Example (uncomment and update):
INSTANCE_NAME="digdir-fdk-prod"
safe_import "google_sql_database_instance.postgresql" "$PROJECT_ID:$INSTANCE_NAME"

# ==========================================
# 9. Persistent Disks
# ==========================================
echo "💿 Importing Persistent Disks..."
safe_import "google_compute_disk.prod_cms_service" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-cms-service"
safe_import "google_compute_disk.prod_community_service" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-community-service"
safe_import "google_compute_disk.prod_kafka_1" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-kafka-1"
safe_import "google_compute_disk.prod_kafka_2" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-kafka-2"
safe_import "google_compute_disk.prod_kafka_3" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-kafka-3"
safe_import "google_compute_disk.prod_mongodb_db" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-mongodb-db"
safe_import "google_compute_disk.prod_rabbitmq" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-rabbitmq"
safe_import "google_compute_disk.prod_reports_store" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-reports-store"
safe_import "google_compute_disk.prod_sparql" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-sparql"
safe_import "google_compute_disk.prod_static_rdf_server" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-static-rdf-server"
safe_import "google_compute_disk.prod_zookeeper_1" "projects/$PROJECT_ID/zones/$ZONE/disks/fdk-prod-zookeeper-1"

# ==========================================
# 10. Disk Snapshot Schedule Policy
# ==========================================
echo "📸 Importing Snapshot Schedule Policy..."
echo "⚠️  TODO: Update snapshot schedule policy name"
echo "    Run: gcloud compute resource-policies list --format='value(name)'"
echo ""

# Example (uncomment and update):
POLICY_NAME="fdk-prod-snapshot-europe-30-days"
safe_import "google_compute_resource_policy.disk_backup_policy" "projects/$PROJECT_ID/regions/$REGION/resourcePolicies/$POLICY_NAME"

# ==========================================
# 11. GKE Cluster
# ==========================================
echo "☸️  Importing GKE Cluster..."
# Get cluster name from: gcloud container clusters list

echo "⚠️  TODO: Update GKE cluster name"
echo "    Run: gcloud container clusters list --format='value(name)'"
echo ""

# Example (uncomment and update):
CLUSTER_NAME="digdir-fdk-prod"
safe_import "google_container_cluster.primary" "projects/$PROJECT_ID/locations/$REGION/clusters/$CLUSTER_NAME"

# ==========================================
# 12. GKE Node Pools
# ==========================================
echo "🔧 Importing GKE Node Pools..."
# Get node pool names from: gcloud container node-pools list --cluster=<cluster-name>

echo "⚠️  TODO: Update node pool names"
echo "    Run: gcloud container node-pools list --cluster=<cluster-name> --region=$REGION --format='value(name)'"
echo ""

# Example (uncomment and update for each node pool):

safe_import "google_container_node_pool.node_pools[\"pool-4\"]" "projects/$PROJECT_ID/locations/$REGION/clusters/$CLUSTER_NAME/nodePools/pool-4"
safe_import "google_container_node_pool.node_pools[\"pool-5\"]" "projects/$PROJECT_ID/locations/$REGION/clusters/$CLUSTER_NAME/nodePools/pool-5"

# ==========================================
# 13. Kubernetes Service Accounts (GCP)
# ==========================================
echo "🔑 Importing Kubernetes-linked GCP Service Accounts..."
echo "⚠️  TODO: Update kubernetes service account names and bindings"
echo ""

# Example (uncomment and update):
# safe_import "google_service_account.kubernetes[\"namespace-sa\"]" "projects/$PROJECT_ID/serviceAccounts/namespace-sa@$PROJECT_ID.iam.gserviceaccount.com"

# ==========================================
# Summary
# ==========================================
echo ""
echo "=========================================="
echo "✅ Import process completed!"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: Review the TODO items above and update the script with actual resource names"
echo ""
echo "Next steps:"
echo "1. Update all TODO sections in this script with actual resource names from your environment"
echo "2. Run 'terraform plan' to verify the configuration matches existing infrastructure"
echo "3. Review any differences and update your .tf files as needed"
echo "4. Once plan shows no changes, your infrastructure is fully imported!"
echo ""