# Apache Polaris

## Setup S3 Credentials

- Garage:
    ```sh
    kubectl exec --stdin --tty -n garage garage-0 -- ./garage key create polaris
    kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket create polaris
    kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket allow --read --write --owner polaris --key polaris
    ```

```sh
kubectl create secret generic -n polaris s3-polaris-credentials --from-literal=access_key_id=my_access_key_id --from-literal=secret_access_key=my_secret_access_key
```

## Create catalog

```sh
export TOKEN=$(
  curl -X POST \
    -u root:s3cr3t \
    -d 'grant_type=client_credentials&scope=PRINCIPAL_ROLE:ALL' \
    http://polaris.localtest.me/api/catalog/v1/oauth/tokens | jq -r .access_token
)

curl -s -v \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Polaris-Realm: POLARIS" \
  http://polaris.localtest.me/api/management/v1/catalogs \
  -d '{
    "catalog": {
      "name": "default",
      "type": "INTERNAL",
      "readOnly": false,
      "properties": {
        "default-base-location": "s3://polaris"
      },
      "storageConfigInfo": {
        "storageType": "S3",
        "endpoint": "http://s3.garage.localtest.me",
        "endpointInternal": "http://s3.garage.localtest.me",
        "pathStyleAccess": true
      }
    }
  }'
```