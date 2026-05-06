#!/bin/bash
set -euo pipefail

export GH_TOKEN=$(get_octopusvariable "GithubAuth")

REPO="tleed5/OctopusVCSTest"
REPO_URL="https://github.com/tleed5/OctopusVCSTest.git"
REPO2="tleed5/ArgoCDTestSource"
REPO2_URL="https://github.com/tleed5/ArgoCDTestSource.git"
TARGET_REVISION=$(get_octopusvariable "Octopus.Action[Create Target Revision Branch].Output.BranchName")
PROJECT_SLUG=$(get_octopusvariable "Octopus.Project.Slug")
ENVIRONMENT_SLUG=$(get_octopusvariable "Octopus.Environment.Slug")
APP_NAMES=("test-app-one" "test-app-two" "test-app-three")
MULTI_SOURCE_APP="test-app-one"

echo "Target revision branch: $TARGET_REVISION"
echo "Applications to create: ${APP_NAMES[*]}"

WORK_DIR=$(mktemp -d)
WORK_DIR2=$(mktemp -d)
trap 'rm -rf "$WORK_DIR" "$WORK_DIR2"' EXIT

# --- Push additional manifests to ArgoCDTestSource ---
gh repo clone "$REPO2" "$WORK_DIR2"
cd "$WORK_DIR2"
git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${REPO2}.git"
git checkout "$TARGET_REVISION"
git config user.email "leedentravis@gmail.com"
git config user.name "Travis Leeden"

SOURCE2_MANIFEST_DIR="ApplicationManifests/${MULTI_SOURCE_APP}"
mkdir -p "$SOURCE2_MANIFEST_DIR"

cat > "${SOURCE2_MANIFEST_DIR}/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: "${MULTI_SOURCE_APP}-service"
spec:
  selector:
    app: "${MULTI_SOURCE_APP}"
  ports:
    - port: 80
      targetPort: 80
EOF
echo "Created: ${SOURCE2_MANIFEST_DIR}/service.yaml"

git add "$SOURCE2_MANIFEST_DIR"
git commit -m "Add manifests for ${MULTI_SOURCE_APP}"
git push origin "$TARGET_REVISION"
COMMIT_SHA_SOURCE2=$(git rev-parse HEAD)
echo "ArgoCDTestSource commit SHA: $COMMIT_SHA_SOURCE2"

# --- Create applications and manifests in OctopusVCSTest ---
gh repo clone "$REPO" "$WORK_DIR"
cd "$WORK_DIR"
git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git"

git checkout "$TARGET_REVISION"

PR_BRANCH="add-applications-$(date +%Y%m%d-%H%M%S)"
git checkout -b "$PR_BRANCH"

git config user.email "leedentravis@gmail.com"
git config user.name "Travis Leeden"

mkdir -p ArgoCD/Applications

for APP_NAME in "${APP_NAMES[@]}"; do
  # Each app gets its own manifest directory so no resources are shared between apps.
  # Shared paths cause cluster-scoped resources (e.g. ClusterRole) to be fought over:
  # syncing one app re-labels them, immediately putting the others out of sync.
  MANIFEST_DIR="ArgoCD/ApplicationManifests/${APP_NAME}"
  mkdir -p "$MANIFEST_DIR"

  cat > "${MANIFEST_DIR}/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "${APP_NAME}-deployment"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: "${APP_NAME}"
  template:
    metadata:
      labels:
        app: "${APP_NAME}"
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.30
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
EOF
  echo "Created: ${MANIFEST_DIR}/deployment.yaml"

  if [[ "$APP_NAME" == "$MULTI_SOURCE_APP" ]]; then
    cat > "ArgoCD/Applications/${APP_NAME}.yaml" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "${APP_NAME}"
  namespace: argocd
  labels: 
    created-by: script
    managed-by: octopus
  annotations:
    argo.octopus.com/project.octopusvcs: "${PROJECT_SLUG}"
    argo.octopus.com/environment.octopusvcs: "${ENVIRONMENT_SLUG}"
    argo.octopus.com/project.argosource: "${PROJECT_SLUG}"
    argo.octopus.com/environment.argosource: "${ENVIRONMENT_SLUG}"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: "${APP_NAME}"
    server: "https://kubernetes.default.svc"
  project: wait-for-argo-apps-step
  sources:
    - path: "${MANIFEST_DIR}"
      name: "octopusvcs"
      repoURL: "${REPO_URL}"
      targetRevision: "${TARGET_REVISION}"
    - path: "ApplicationManifests/${APP_NAME}"
      name: "argosource"
      repoURL: "${REPO2_URL}"
      targetRevision: "${TARGET_REVISION}"
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
EOF
  else
    cat > "ArgoCD/Applications/${APP_NAME}.yaml" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "${APP_NAME}"
  namespace: argocd
  labels: 
    created-by: script
    managed-by: octopus
  annotations:
    argo.octopus.com/project: "${PROJECT_SLUG}"
    argo.octopus.com/environment: "${ENVIRONMENT_SLUG}"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: "${APP_NAME}"
    server: "https://kubernetes.default.svc"
  project: wait-for-argo-apps-step
  source:
    path: "${MANIFEST_DIR}"
    repoURL: "${REPO_URL}"
    targetRevision: "${TARGET_REVISION}"
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
EOF
  fi
  echo "Created: ArgoCD/Applications/${APP_NAME}.yaml"
done

git add ArgoCD/Applications/ ArgoCD/ApplicationManifests/
git commit -m "Add Argo CD test applications for branch $TARGET_REVISION"
COMMIT_SHA=$(git rev-parse HEAD)
echo "OctopusVCSTest commit SHA: $COMMIT_SHA"

git push origin "$PR_BRANCH"

PR_URL=$(gh pr create \
  --repo "$REPO" \
  --head "$PR_BRANCH" \
  --base "$TARGET_REVISION" \
  --title "Add Argo CD test applications" \
  --body "Adds test Argo CD application definitions to ArgoCD/Applications for deployment via app of apps.")

echo "Pull request created: $PR_URL"

APP_NAMES_CSV=$(IFS=','; echo "${APP_NAMES[*]}")
COMMIT_SHA_ALL=$(printf '%s\n' "$COMMIT_SHA" "$COMMIT_SHA_SOURCE2" | sort -u | tr '\n' ',' | sed 's/,$//')

set_octopusvariable "ApplicationNames" "$APP_NAMES_CSV"
set_octopusvariable "CommitSha" "$COMMIT_SHA_ALL"

echo "Output variable 'ApplicationNames' set to: $APP_NAMES_CSV"
echo "Output variable 'CommitSha' set to: $COMMIT_SHA_ALL"
