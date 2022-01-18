## Create a new Helm-Chart release

- Run `helm dep update` to update chart dependencies
- Set the version number
  - `./Chart.yaml` 
  - `./examples/aws-eks/README.md`
  - `./examples/google-gke/README.md`
- Update the `CHANGELOG.md`
- Commit and Push
- Create a release on GitHub with tag schema: `apim-helm-v2.2.0`