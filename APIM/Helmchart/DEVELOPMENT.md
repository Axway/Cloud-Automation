## Create a new Helm-Chart release

To create a release follow these steps:

- Update the `CHANGELOG.md`
  - Make sure you set the next release version
  - Change: `[Unreleased]` to for example [2.10.1] 2022-06-26
- The version numbers referenced in `./Chart.yaml`, `./examples/aws-eks/README.md` and `./examples/google-gke/README.md` will be updated automatically
- Create a release on GitHub with tag schema: `apim-helm-2.8.0`
  - the release version is extracted based on the given semver version including the additional characters.
  - for example: 
    `apim-helm-2.8.0-alpha` --> `2.8.0-alpha`
    `apim-helm-2.8.0` --> `2.8.0`
