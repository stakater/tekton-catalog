# Stakater Validate Environment
Checks if HelmRelease Deployed by the environment is successfully released or not.

# Test
- Clone the task folder and run `helm template .` inside the chart directory.

- Copy the generated yaml and change the kind from `ClusterTask` to `Task`.

- Deploy a demo environment. (Environment name should be the Namespace name of your deployment)

```
apiVersion: tronador.stakater.com/v1alpha2
kind: Environment
metadata:
  name: gabbar-muhammad-mustafa-stakater-sandbox
spec:
  application:
    gitRepository:
      gitImplementation: go-git
      interval: 1m0s
      ref:
        branch: main
      timeout: 20s
      url: 'https://github.com/stakater-lab/stakater-nordmart-review'
    release:
      chart:
        spec:
          chart: deploy
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: GitRepository
            name: dte-main
          version: '*'
      interval: 1m0s
      releaseName: main
      values:
        application:
          deployment:
            image:
              repository: >-
                docker.io/stakater/stakater-nordmart-review-ui
              tag: 1.0.24-a
  namespaceLabels:
    kubernetes.io/metadata.name: gabbar-muhammad-mustafa-stakater-sandbox
    stakater.com/tenant: gabbar
    stakater.com/kind: sandbox
```

- Deploy a demo taskrun to check if the task is functioning properly.

```
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: tr-validate-environment
  namespace: gabbar-build
spec:
  params:
  - name: ENVIRONMENT_NAME
    value: gabbar-muhammad-mustafa-stakater-sandbox
  - name: TIMEOUT
    value: '300'
  serviceAccountName: stakater-tekton-builder
  taskRef:
    kind: Task
    name: stakater-validate-environment-1.0.0-testing
  timeout: 1h0m0s
  workspaces:
    - name: source
      emptyDir: {}
  podTemplate:
    tolerations:
      - effect: NoExecute
        key: pipeline
        operator: Exists
```
