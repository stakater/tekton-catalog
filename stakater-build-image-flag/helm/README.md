# Stakater Cluster Task for Build Image Flag

`stakater-build-image-flag` clustertask checks the difference between 2 commits using `git diff` command, to determine if the image should be built or not. It sets the flag value `true` if difference exists.

# Parameters

- **OLD_COMMIT**: The last git revision in `main` branch
- **NEW_COMMIT**: The current git revision in `main` branch

# Results

- **BUILD_IMAGE**: Flag for determining whether image should be built or not. Default value is `false`.

# Workspaces

- **source**: A workspace that contains the fetched git repository.
