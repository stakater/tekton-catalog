# create environment


## tests
- Clone the task folder and run helm template . inside the chart directory.

- Copy the generated yaml and change the kind from ClusterTask to Task

- Create a pipeline that contains git-clone and create environment task.
```
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: p-create-environment
  namespace: gabbar-build
spec:
  tasks:
    - name: git-clone
      params:
        - name: url
          value: "https://github.com/stakater-lab/stakater-nordmart-review"
        - name: revision
          value: "a65fd7308c1b1a1a9f284773ba0d0e934d93f1d5"
        - name: depth
          value: '0'
      taskRef:
        kind: ClusterTask
        name: git-clone
      workspaces:
        - name: output
          workspace: source
    - name: create-env
      params:
      - name: CREATE_ON_CLUSTER
        value: 'true'
      - name: REPO_NAME
        value: 'stakater-nordmart-review'
      - name: PR_NUMBER
        value: '353'
      - name: GIT_URL
        value: 'https://github.com/stakater-lab/stakater-nordmart-review'
      - name: GIT_BRANCH
        value: 'AsfaMumtaz-patch-1'
      - name: IMAGE_TAG
        value: 'snapshot-pr-353-a65fd730'
      - name: IMAGE_REPO
        value: >-
          'nexus-docker-stakater-nexus.apps.devtest.vxdqgl7u.kubeapp.cloud/stakater-nordmart-review'
      - name: DEFAULT_BRANCH
        value: 'main'
      - name: GITHUB_ORGANIZATION
        value: stakater-lab
      runAfter:
        - git-clone
      taskRef:
        kind: Task
        name: stakater-create-environment-1.0.0-testing
      workspaces:
        - name: output
          workspace: source
  workspaces:
  - name: source
---
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: pr-create-environment
  namespace: gabbar-build
spec:
  pipelineRef:
    name: p-create-environment
  serviceAccountName: stakater-tekton-builder
  workspaces:
    - name: source
      volumeClaimTemplate:
        metadata:
          creationTimestamp: null
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
```
- Verify if the task runs successfully.