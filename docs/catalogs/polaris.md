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