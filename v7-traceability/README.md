
## Prerequisites

Before the chart can be installed make sure to have the secrets installed/available.

i.e if you look at line 31(secrets) in the values.yaml file, you will notice we are referencing two files.

Required credentials can be applied by using the below format for the secret. 
Make sure all the values are base64 encoded before applying it in the cluster.

kubectl apply -f <creds-FILENAME.yaml>
``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: traceability-creds
type: Opaque
stringData:
  APIMANAGER_AUTH_USERNAME: ""
  APIMANAGER_AUTH_PASSWORD: ""
  APIGATEWAY_AUTH_USERNAME: ""
  APIGATEWAY_AUTH_PASSWORD: ""
```

kubectl apply -f <keys-FILENAME.yaml>
``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: traceability-keys
data:
  private_key: <PRIVATE_KEY_BASE64>
  public_key: <PUBLIC_KEY_BASE64>
```