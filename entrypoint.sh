#!/bin/sh -l

# Exit on error.
set -e;

CURRENT_DIR=$(pwd);

run_kubeval() {
    # Validate all generated manifest against Kubernetes json schema
    cd "$1"
    VALUES_FILE="$2"
    mkdir helm-output;
    helm template --values "$VALUES_FILE" --output-dir helm-output .;
    find helm-output -type f -exec \
        /kubeval/kubeval \
            "-o=$OUTPUT" \
            "--strict=$STRICT" \
            "--kubernetes-version=$KUBERNETES_VERSION" \
            "--openshift=$OPENSHIFT" \
            "--ignore-missing-schemas=$IGNORE_MISSING_SCHEMAS" \
        {} +;
    rm -rf helm-output;
}

helm repo add stable https://kubernetes-charts.storage.googleapis.com/;

for CHART in "$CHARTS_PATH"/*; do
    echo "Validating $CHART Helm Chart...";
    cd "$CURRENT_DIR/$CHART";
    helm dependency build;

    if [ -d "ci" ]; then
        for VALUES_FILE in ci/*-values.yaml; do
            echo "Validating $CHART Helm Chart using $VALUES_FILE values file...";
            run_kubeval "$(pwd)" "$VALUES_FILE"
        done
    else
        run_kubeval "$(pwd)" "/dev/null"
    fi
done
