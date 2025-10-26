# Iceberg Query

## Context
Query Iceberg tables using the Trino engine, Polaris catalog and Garage Object Storage

## Setup
- Setup Garage bucket and key
```sh
kubectl exec --stdin --tty -n garage garage-0 -- ./garage key create polaris-default
kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket create polaris-default
kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket allow --read --write --owner polaris-default --key polaris-default
```
```sh
kubectl create secret generic -n polaris s3-polaris-credentials --from-literal=access_key_id=my_access_key_id --from-literal=secret_access_key=my_secret_access_key
kubectl create secret generic -n trino s3-polaris-credentials --from-literal=access_key_id=my_access_key_id --from-literal=secret_access_key=my_secret_access_key
```

- Create Polaris catalog
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
        "endpoint": "http://garage.garage:3900",
        "region": "garage",
        "pathStyleAccess": true,
        "stsUnavailable": true
      }
    }
  }'
```

- Make sure Trino is correctly setup for this catalog : 
```yaml
catalogs:
    ...
    polaris: |
        connector.name=iceberg
        iceberg.catalog.type=rest
        iceberg.rest-catalog.uri=http://polaris.polaris:8181/api/catalog
        iceberg.rest-catalog.warehouse=polaris-default
        iceberg.rest-catalog.security=OAUTH2
        iceberg.rest-catalog.oauth2.server-uri=http://polaris.polaris:8181/api/catalog/v1/oauth/tokens
        iceberg.rest-catalog.oauth2.credential=root:s3cr3t
        iceberg.rest-catalog.oauth2.scope=PRINCIPAL_ROLE:ALL
        iceberg.rest-catalog.oauth2.token-refresh-enabled=true
        iceberg.rest-catalog.nested-namespace-enabled=true
```
- Connect to trino
```sh
kubectl exec --stdin --tty -n trino trino-coordinator-//////////-////// -- trino
#>>> trino>
```

## Create data in Iceberg
```sql
CREATE SCHEMA IF NOT EXISTS "polaris-default"."cookbook";
CREATE SCHEMA IF NOT EXISTS "polaris-default"."cookbook.public";
CREATE TABLE IF NOT EXISTS "polaris-default"."cookbook.public".people (id INTEGER, name VARCHAR);
INSERT INTO "polaris-default"."cookbook.public".people (id, name) VALUES (1, 'Alice'), (2, 'Bob');
SELECT name FROM "polaris-default"."cookbook.public".people;
```

Clean data
```sql
DROP TABLE "polaris-default"."cookbook.public".people;
DROP SCHEMA "polaris-default"."cookbook.public";
DROP SCHEMA "polaris-default"."cookbook";
```