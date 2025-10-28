# Apache Polaris

## Setup S3 Credentials

- Garage:
    ```sh
    kubectl exec --stdin --tty -n garage garage-0 -- ./garage key create polaris-default
    kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket create polaris-default
    kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket allow --read --write --owner polaris-default --key polaris-default
    ```

```sh
kubectl create secret generic -n polaris s3-polaris-credentials --from-literal=access_key_id=my_access_key_id --from-literal=secret_access_key=my_secret_access_key
```

- Minio:
  ```sh
  kubectl create secret generic -n polaris s3-polaris-credentials --from-literal=access_key_id=minioadmin --from-literal=secret_access_key=minioadmin
  ```

## Create catalog

```sh
export TOKEN=$(
  curl -X POST \
    -u root:s3cr3t \
    -d 'grant_type=client_credentials&scope=PRINCIPAL_ROLE:ALL' \
    http://polaris.localtest.me/api/catalog/v1/oauth/tokens | jq -r .access_token
)

curl -s \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Polaris-Realm: POLARIS" \
  http://polaris.localtest.me/api/management/v1/catalogs \
  -d '{
    "catalog": {
      "name": "polaris-default",
      "type": "INTERNAL",
      "readOnly": false,
      "properties": {
        "default-base-location": "s3://polaris-default"
      },
      "storageConfigInfo": {
        "storageType": "S3",
        "endpoint": "http://minio.minio:9000",
        "region": "us-east-1",
        "pathStyleAccess": true
      }
    }
  }'

curl \
  -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: application/json' \
  -X PUT \
  http://polaris.localtest.me/api/management/v1/catalogs/polaris-default/catalog-roles/catalog_admin/grants \
  -d '{"type":"catalog", "privilege":"CATALOG_MANAGE_CONTENT"}'
```