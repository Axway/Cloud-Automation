## Create a new Helm-Chart release

- Run `helm dep update` to update chart dependencies
- Update the `CHANGELOG.md`
- The version numbers referenced in `./Chart.yaml`, `./examples/aws-eks/README.md` and `./examples/google-gke/README.md` will be updated automatically
- Commit and Push changed to master
- Create a release on GitHub with tag schema: `apim-helm-2.8.0`
  - the release version is extracted based on the given semver version including the additional characters.
  - for example: 
    `apim-helm-2.8.0-alpha` --> `2.8.0-alpha`
    `apim-helm-2.8.0` --> `2.8.0`