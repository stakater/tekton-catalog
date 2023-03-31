# STAKATER-SET-COMMIT-STATUS

Updates status for a commit.

## Tiltfile-clustertask

### update_settings(max_parallel_updates = 1) 

This tilt function allows a maximum of one parallel updates. This helps resources that are dependent on each other to wait on their dependencies to become available.

### Create Clustertask

Installs Helm chart for clustertask that lives in `/helm` directory.

### Create git-token Secret

`kubectl` command is used to create `git-token` secret in instance namespace. This is a fine-grained personal access token (PAT), and is used by stakater-set-commit-status clustertask to update commit status on git. It is added as environment variable in repository secrets, and passed to tiltfile from github workflow
```
    env: 
        TEST_GIT_REPO_SECRET: ${{ secrets.TEST_GIT_REPO_SECRET }}
```
### Create TaskRun

A taskrun is created with hardcoded values required by the clustertask to test out the functionality. It is placed inside `tests/raw-manifests` directory. Following are the hardcoded parameters:

1. **PIPELINE_NAME:** Name of pipeline
2. **PIPELINE_NAMESPACE:** Namespace of pipeline
3. **TEKTON_BASE_URL:** Tekton base URL
4. **GIT_SECRET_NAME:** Name of secret that contains PAT token
5. **WEBHOOK_PAYLOAD:** Webhook payload normally consists of all payload received after an event has occurred on github. For testing purpose, values from payload specific to testing of this clustertask are hardcoded only. These values are
    1. **repository.fullname:** Name of test repository
    2. **repository.url:** URL of test repository in this format
    3. **head_commit.id:** ID of a commit from test repository against which the clustertask is to be tested.
6. **STATE:** State that is to be set in git for this commit
7. **DESCRIPTION**: Description message to be added for this commit
8. **CONTEXT:** Context of message

This taskrun also requires a service account named `pipeline`. Its manifest is also added to `tests/raw-manifest`.

`k8s_yaml` method of Tilt deploys these two resources. Resources deployed through `k8s_yaml` are not categorized in Tilt. Taskrun and ServiceAccount here are categorized using `k8s_resource` method, so that other resources in Tilt can be made to wait for their availability using `resource_deps`.

### Script for validating Taskrun

`tilt ci` is being used to setup and test the clustertask workflow. A script is added to the testing workflow that checks the created taskrun CR on the basis of `status.condition.[*].status` & `status.condition.[*].reason` for failure or success, and exits with zero (success) or non-zero (failure) code on that basis.

## Tiltfile-delete-clustertask

**include('Tiltfile-clustertask')** includes the tiltfile used for setup. `tilt down` command uninstalls/removes any resources (e.g. taskrun, serviceAccount) created. 
**delete_clustertask()** uninstalls clustertask chart.