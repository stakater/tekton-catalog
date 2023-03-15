# Stakater Cluster Task Buildah

`stakater-buildah` clustertask builds source into a container image and then pushes it to a container registry. It uses Project Atomic's Buildah build tool for building from Dockerfiles, using its `buildah bud` command. This command executes the directives in the Dockerfile to assemble a container image, then pushes that image to a container registry.

# Parameters

- **IMAGE**: Reference of the image buildah will produce.
- **BUILDER_IMAGE**: The location of the buildah builder image.
- **STORAGE_DRIVER**: Set buildah storage driver.
- **DOCKERFILE**: Path to the Dockerfile to build.
- **CONTEXT**: Path to the directory to use as context.
- **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a non-TLS registry)
- **FORMAT**: The format of the built container, oci or docker.
- **BUILD_EXTRA_ARGS**: Extra parameters passed for the build command when building images.
- **PUSH_EXTRA_ARGS**: Extra parameters passed for the push command when pushing images.
- **BUILD_IMAGE**: Flag specifying whether image should be built again.
- **IMAGE_REGISTRY**: Image registry url.
- **CURRENT_GIT_TAG**: Current version of the application/image in dev.

# Results

- **IMAGE_DIGEST**: Digest of the image just built.

# Workspaces

- **source**: A workspace that contains the fetched git repository.
- **buildah-git-dependency-token**: A mount point for token. 