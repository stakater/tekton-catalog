# Stakater Cluster Task Checkov Scan

Checkov is a static code analysis tool for scanning dockerfiles for misconfigurations that may lead to security or compliance problems.`cheeckov-scan` clustertask uses command `checkov -d . -s`.

# Parameters

- **BUILD_IMAGE**: Flag specifying whether image should be built again.

# Workspaces

- **source**: A workspace that contains the fetched git repository.