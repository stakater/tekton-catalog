# buildah as user

Updated image, storage driver, volume mounts, security context to run as rootless from https://docs.openshift.com/container-platform/4.13/cicd/pipelines/unprivileged-building-of-container-images-using-buildah.html

This task requires the following ServiceAccount, Role, Rolebinding and SecurityContextConstraint

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipelines-sa-userid-1000 
---
kind: SecurityContextConstraints
metadata:
  annotations:
  name: pipelines-scc-userid-1000 
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true 
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
groups:
- system:cluster-admins
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
- KILL
runAsUser: 
  type: MustRunAs
  uid: 1000
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pipelines-scc-userid-1000-clusterrole 
rules:
- apiGroups:
  - security.openshift.io
  resourceNames:
  - pipelines-scc-userid-1000
  resources:
  - securitycontextconstraints
  verbs:
  - use
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipelines-scc-userid-1000-rolebinding 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pipelines-scc-userid-1000-clusterrole
subjects:
- kind: ServiceAccount
  name: pipelines-sa-userid-1000
```

In your PipelineRun you can use a taskRunSpecs to force it to use that serviceaccount instead of the normal one :
```
  taskRunSpecs:
    - pipelineTaskName: stakater-buildah-as-user
      taskServiceAccountName: pipelines-sa-userid-1000
```

Ref:
- https://docs.openshift.com/container-platform/4.13/cicd/pipelines/unprivileged-building-of-container-images-using-buildah.html
- https://blog.chmouel.com/2022/03/07/running-tasks-as-non-root-on-openshift-pipelines/
- https://gist.github.com/chmouel/8242806100ffa7164bb63d7d5b0a593d
- https://github.com/containers/buildah/blob/main/docs/tutorials/05-openshift-rootless-build.md
