# TEKTON-CATALOG

This repository contains a catalog of Clustertask resources, which are designed to be reusable in many pipelines.

Each Task is provided in a separate directory along with a README.md and a Helm Chart, so you can choose which Tasks to install on your cluster. A directory can hold one task and multiple version.

## Github Actions Runner Controller on Kubernetes

We need to setup and deploy Actions Runner Controller on Kubernetes cluster. This allows us to run self hosted runners for running Github Actions jobs/workflows.
We can deploy Actions Runner Controller (ARC) using  [saap-addons](https://github.com/stakater-ab/saap-addons/tree/main/actions-runner-controller)

- Clone the saap-addons repository locally

      git clone https://github.com/stakater-ab/saap-addons.git
      cd saap-addons/actions-runner-controller

- Login to the cluster where you want to deploy Actions Runner Controller (ARC).

      oc login --token=sha256~ABCabcABCabc --server=https://api.my.cluster.url:6443

- Add a personal access token or fine grained token in values-local.yaml file.

      github_token: github_pat-12jd912i3123i1

    Note: Find the permission required for token [here](https://github.com/stakater-ab/saap-addons/tree/main/actions-runner-controller).

- Run the following command to deploy Actions Runner Controller (ARC).

      tilt up

- We need to provide additional permissions to Actions Runner Controller Service Account.

    | Actions | Group                | Resources                         |
    |---------|----------------------|-----------------------------------|
    | *       | operators.coreos.com | operatorgroups,subscriptions      |
    | *       | operator.tekton.dev  | tektonconfigs,tektoninstallersets |
    | *       | tekton.dev           | clustertasks,taskruns             |


- Add following RBAC to `saap-addons/actions-runner-controller/helm/templates/clusterrole.yaml`

      - verbs:
          - '*'
          apiGroups:
          - operators.coreos.com
          resources:
          - operatorgroups
          - subscriptions
      - verbs:
          - '*'
          apiGroups:
          - operator.tekton.dev
          resources:
          - tektonconfigs
          - tektoninstallersets
      - verbs:
          - '*'
          apiGroups:
          - tekton.dev
          resources:
          - clustertasks
          - taskruns

- Create the following RunnerDeployment (CR) on the cluster

        apiVersion: actions.summerwind.dev/v1alpha1
        kind: RunnerDeployment
        metadata:
        name: tekton-catalog
        namespace: stakater-actions-runner-controller
        spec:
        template:
            metadata: {}
            spec:
            dockerdContainerResources: {}
            image: ''
            labels:
                - sno1
            repository: stakater/tekton-catalog
            serviceAccountName: actions-runner-controller-runner-deployment

- Open your github repository and Navigate to `Settings > Actions > Runners`. You will see a runner present.

## Github Workflow

Each Clustertasks in tekton-catalog repository has a testing workflow. These workflows run on Github Action Runners deployed on one of Stakater Single Node Openshift (SNO) clusters. Each workflow contains a job named `clustertask-test-run` designed specifically to test out the functionality. Following are the steps of this job:

1. **Checkout code:** Checks out code from pull request branch.
2. **Install CLI tools:** Installs CLI tools from Openshift Mirror.
3. **Login to Cluster**: Logs in to SNO cluster.
4. **Setup Helm:** Installs `helm` CLI to perform helm installs, etc.
5. **Login to Container Registry:** Logs in to Container registry to pull/push charts & images.
6. **Install kubectl:** Installs `kubectl` CLI.
7. **Install Tilt:** Installs `tilt` CLI, which is used in these workflows to install dependencies required for testing, and the clustertask as well.
8. **Tilt CI - Setup Dependencies:** Tilt CI starts Tilt and runs resources defined in the Tiltfile. Exits with failure if any resource fails or any server crashes. Exits with success if all tasks have completed successfully and all servers are healthy. In this step, depedencies required by clustertask are installed. [Find this file here](.github/Tiltfile-setup-dependencies)
9. **Tilt CI - Run Clustertask:** Clustertask chart is installed using Helm and a TaskRun with mandatory hardcoded values is created that runs and tests the clustertask.
10. **Tilt down - Clustertask:** Clustertask chart is uninstalled, Taskrun is deleted.
11. **Tilt down - Dependencies:** All dependencies installed previously are uninstalled to make sure that the runner cluster is in pre-run state. [Find this file here](.github/Tiltfile-delete-dependencies)

## Tiltfile-setup-dependencies

Tiltfile-setup-depedencies contains underlying dependencies required to test a clustertask, which are of repetitive in nature, e.g. Pipelines Operator is a dependency that is required by all clustertasks. Such dependencies are added in a file named `Tiltfile-setup-dependencies` and placed in `.github` directory, and referenced in clustertasks required. The purpose of separating out this config is to avoid repetition of code. 

Following are the Helm charts deployed by this Tiltfile.

1. Pipelines Operator
2. Pipelines Instance

Note: User needs to be logged in to `ghcr.io` to be able to install these helm-charts 

### Configure tilt-settings.json

`tilt-settings.json` files contains configuration used by Tiltfile to apply defined resource to the cluster. Users have to update these values according to their context.

**allow_k8s_contexts:** 
- Default value is `stakater-actions-runner-controller/kubernetes-default-svc:443/system:serviceaccount:stakater-actions-runner-controller:actions-runner-controller-runner-deployment` which is used by github actions.
- For local testing, Update the value with SNO context. You can get the current context by running `oc config current-context`. 
- Similar to `default/api-vmw-sno1-lab-kubeapp-cloud:6443/kube:admin`.
- Run the following command to tell git to assume this file is unchanged as it contains configuration required by Github Actions.

      git update-index --assume-unchanged tilt-settings.json

**default_registry:** 
- Configure this value according to your context `image-registry-openshift-image-registry.apps.[CLUSTER-NAME].[CLUSTER-ID].kubeapp.cloud`.
- Alternatively, you can navigate to `Network > Routes` in `openshift-image-registry` namespace on Openshift Console to find image registry url.

### update_settings(max_parallel_updates = 1) 

This tilt function allows a maximum of one parallel updates. This helps resources that are dependent on each other to wait on their dependencies to become available. 

### Install Pipeline Operator

Tiltfile method `local_resource` installs Pipelines Operator using helm install cmd from Stakater ghcr.io OCI registry. A wait condition is added for Pipelines Operator installation, waiting for operator deployment to get in Available state. This condition times out after 300s, and Tilt process exits with failure.

### Install Pipeline Instance

Helm chart for Pipelines Instance is installed after successful operator installation. This is also installed with the same method explained in previous step. Pipelines instance chart contains `TektonConfig` resource, that in return installs underlying Tekton resources defined. A wait condition is added for Pipelines Instance installation, waiting for TektonConfig resource to get in Ready state, meaning all defined resources are installed and ready. This condition also times out after 300s, and Tilt process exits with failure.

## Tiltfile-delete-dependencies

**delete_instance()** method is called first. It uninstalls Helm chart for Pipeline Instance. If Pipelines Instance chart does not exist, or there seems to be another error, tilt exits with failure, without removing/deleting other resources defined in this tilt-delete file. Hence, `|| true` is added to the uninstall command here that does not let tilt exit with failure under any condition, and ensures proper clean up.

**delete_operator()** method uninstalls Pipelines Operator Helm chart.

**patch_crds()** executes `kubectl` command to get and delete all TektonInstallerSets with `--wait=false` flag, meaning that if a resource gets stuck in deletion due to finalizers in metadata, do not wait for it to complete. This is covered in the next command that patches the remaining TektonInstallerSets and remove finalizers.

**delete_crds()** method deletes all CRDs from `operator.tekton.dev` API group.

# Local testing

### Setting up dependencies:

`tilt up -f .github/Tiltfile-setup-dependencies`

### Deleting dependencies:

`tilt down -f .github/Tiltfile-setup-dependencies`