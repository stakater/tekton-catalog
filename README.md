# TEKTON-CATALOG

This repository contains a catalog of Clustertask resources, which are designed to be reusable in many pipelines.

Each Task is provided in a separate directory along with a README.md and a Helm Chart, so you can choose which Tasks to install on your cluster. A directory can hold one task and multiple version.

## Github Workflow

Clustertasks in tekton-catalog repository each has a testing workflow. These workflows run on Github Action Runners deployed on one of Stakater Single Node Openshift (SNO) clusters. Each workflow contains a job named `clustertask-test-run` designed specifically to test out the functionality. Following are the steps of this job:

1. **Checkout code:** Checks out code from pull request branch.
2. **Install CLI tools:** Installs CLI tools from Openshift Mirror
3. **Login to Cluster**: Logs in to SNO cluster
4. **Setup Helm:** Sets up `helm` CLI to perform helm installs, etc.
5. **Login to Container Registry:** Logs in to Container registry to pull/push charts & images
6. **Install kubectl:** Installs `kubectl` CLI
7. **Install Tilt:** Tilt is being installed, which is used in these workflows to install dependencies required for testing, and the clustertask as well.
8. **Tilt CI - Setup Dependencies:** Tilt CI starts Tilt and runs resources defined in the Tiltfile. Exits with failure if any build fails or any server crashes. Exits with success if all tasks have completed successfully and all servers are healthy. In this step, depedencies required by clustertask are installed.
9. **Tilt CI - Run Clustertask:** Clustertask chart is installed using Helm and a TaskRun with mandatory hardcoded values is created that runs and tests the clustertask.
10. **Tilt down - Clustertask:** Clustertask chart is uninstalled, Taskrun is deleted.
11. **Tilt down - Dependencies:** All dependencies installed previously are uninstalled to make sure that the runner cluster is in pre-run state.

## Tiltfile-setup-dependencies

Tiltfile-setup-depedencies contains underlying dependencies required to test a clustertask, which are of repetitive in nature, e.g. Pipelines Operator is a dependency that is required by all clustertasks. Such dependencies are added in a file named `Tiltfile-setup-dependencies` and placed in `.github` directory, and referenced in clustertasks required. The purpose of separating out this config is to avoid repetition of code. 

Following are the Helm charts deployed by this Tiltfile.

1. Pipelines Operator
2. Pipelines Instance

Note: User needs to be logged in to `ghcr.io` to be able to install these helm-charts 

### Configure tilt-settings.json

`tilt-settings.json` files contains configuration used by Tiltfile to apply defined resource to the cluster. Users have to update these values according to their context.

**allow_k8s_contexts:** For local testing, default value for SNOs is `default/api-vmw-sno1-lab-kubeapp-cloud:6443/kube:admin`. Change this to `stakater-actions-runner-controller/kubernetes-default-svc:443/system:serviceaccount:stakater-actions-runner-controller:actions-runner-controller-runner-deployment` before pushing the code to github for testing workflow.

**default_registry**: Configure this value according to your context `image-registry-openshift-image-registry.apps.[CLUSTER-NAME].[CLUSTER-ID].kubeapp.cloud`

### Install Pipeline Operator
Tiltfile method `local_resource` installs Pipelines Operator using helm install cmd from Stakater ghcr.io OCI registry. A wait condition is added for Pipelines Operator installation, waiting for operator deployment to get in Available state. This condition times out after 300s, and Tilt process exits with failure.

### Install Pipeline Instance
Helm chart for Pipelines Instance is installed after successful operator installation. This is also installed with the same method explained in previous step. Pipelines instance chart contains `TektonConfig` resource, that in return installs underlying Tekton resources defined. A wait condition is added for Pipelines Instance installation, waiting for TektonConfig resource to get in Ready state, meaning all defined resources are installed and ready. This condition also times out after 300s, and Tilt process exits with failure.

## Tiltfile-clustertask

### Create Clustertask