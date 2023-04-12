# STAKATER-BUILDAH
Builds and Pushes Image to specified Image Registry

## Tiltfile-clustertask

### update_settings(max_parallel_updates = 1) 

This tilt function allows a maximum of one parallel updates. This helps resources that are dependent on each other to wait on their dependencies to become available.

### Prerequisite
- Requires [tekton-pipelines-scc](https://github.com/stakater-ab/saap-addons-charts/blob/main/stakater/tekton-pipeline/templates/scc.yaml) as task runs in privileged context.
- Requires a service account with image-builder role and role to use security context ie. tekton-pipelines-scc.

### Create Clustertask

Installs Helm chart for clustertask that lives in `/helm` directory.

### Create Pipeline and PipelineRun

A pipelinerun and pipeline is created with hardcoded values required by the clustertask to test out the functionality. It is placed inside `tests/raw-manifests` directory. Following are the hardcoded parameters:

1. **IMAGE:** Name of image with host, path and tag.
2. **TLSVERIFY:** Skip image registry verification.
3. **FORMAT:** The format of the built container, oci or docker
4. **BUILD_IMAGE:** Whether to build image or simply tag previous version
5. **IMAGE_REGISTRY:** Image registry url
8. **CURRENT_GIT_TAG:** Corresponds to Git Tag of Repository

This tasks requires a workspace `source` that has source code along with Dockerfile.

This pipeline run also requires a service account named `pipeline-sa`. This service account needs `system:image-builder` role and permission to use `tekton-pipelines-scc`. Its manifest is also added to `tests/raw-manifest`.

`k8s_yaml` method of Tilt deploys these two resources. Resources deployed through `k8s_yaml` are not categorized in Tilt. Taskrun and ServiceAccount here are categorized using `k8s_resource` method, so that other resources in Tilt can be made to wait for their availability using `resource_deps`.

### Script for validating PipelineRun

`tilt ci` is being used to setup and test the clustertask workflow. A script is added to the testing workflow that checks the created PipelineRun CR on the basis of `status.condition.[*].status` & `status.condition.[*].reason` for failure or success, and exits with zero (success) or non-zero (failure) code on that basis.

## Tiltfile-delete-clustertask

**include('Tiltfile-clustertask')** includes the tiltfile used for setup. `tilt down` command uninstalls/removes any resources (e.g. taskrun, serviceAccount) created. 
**delete_clustertask()** uninstalls clustertask chart.

# Local testing

### Setting up dependencies:

`tilt up -f stakater-buildah/tests/Tiltfile-clustertask`

### Deleting dependencies:

`tilt down -f stakater-buildah/tests/Tiltfile-delete-clustertask`