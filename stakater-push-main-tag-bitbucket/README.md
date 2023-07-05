# Stakater Cluster Task for Pushing Tags to Bitbucket Repository

We have a separate task for github and gitlab that supports both ssh and token for pushing the tag.
Bitbucket ssh tokens are read only, so ssh support for this task could not be added.
The task script of this task also differs for the one in stakater-git-push-main-tag.

## Local Development

### Install

```
tilt up
```

### Teardown

```
tilt down
```