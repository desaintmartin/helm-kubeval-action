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

# Parse helm repos located in the $CONFIG_FILE file / Ignore commented lines (#)
while read REPO_CONFIG
do
    case "$REPO_CONFIG" in \#*) continue ;; esac
    REPO=$(echo $REPO_CONFIG | cut -d '=' -f1);
    URL=$(echo $REPO_CONFIG | cut -d '=' -f2);
    helm repo add $REPO $URL;
done < $CONFIG_FILE

# For all charts (i.e for every directory) in the directory
for CHART in "$CHARTS_PATH"/*/; do
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
    echo "Cleanup $(pwd)/charts directory after we are done running Kubeval"
    rm -rf $(pwd)/charts/
done
