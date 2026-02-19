#!/bin/bash
# Namespace-aware deployment script

NAMESPACE=${1:-staging}  # Default to staging
DOMAIN=${2:-all}        # Default to all domains

NAMESPACE_DIR="./namespaces/$NAMESPACE"
SHARED_DOMAIN_DIR="./shared-domains"

if [ ! -d "$NAMESPACE_DIR" ]; then
    echo "Error: Namespace '$NAMESPACE' not found"
    exit 1
fi

# Deploy to specific domain or all domains
if [ "$DOMAIN" = "all" ]; then
    for domain_config in "$NAMESPACE_DIR"/*.conf; do
        deploy_to_domain "$NAMESPACE" "$domain_config"
    done
else
    deploy_to_domain "$NAMESPACE" "$NAMESPACE_DIR/$DOMAIN.conf"
fi

deploy_to_domain() {
    local ns=$1
    local config=$2
    local domain=$(basename "$config" .conf)
    
    source "$config"  # Load rsync config, host, path, etc.
    
    echo "Deploying $domain to $RSYNC_HOST in namespace: $ns"
    rsync -avzr --delete \
        "$NAMESPACE_DIR/$domain/" \
        "$RSYNC_USER@$RSYNC_HOST:$RSYNC_PATH/$ns/$domain/"
}