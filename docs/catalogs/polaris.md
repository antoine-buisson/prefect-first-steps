# Apache Polaris

## Setup S3 Credentials
```sh
kubectl create secret generic -n polaris s3-polaris-credentials --from-literal=access_key_id=my_access_key_id --from-literal=secret_access_key=my_secret_access_key
```