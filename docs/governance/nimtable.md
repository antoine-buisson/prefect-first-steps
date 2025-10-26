# Nimtable

## Requirements
- Start an Object Storage
- Create a catalog on Polaris

## Create a new catalog
- From CLI Parameters
```sh
spark-sql \
--conf spark.sql.catalog.polaris-default=org.apache.polaris.spark.SparkCatalog \
--conf spark.sql.catalog.polaris-default.type=rest \
--conf spark.sql.catalog.polaris-default.uri=http://polaris.polaris:8181/api/catalog \
--conf spark.sql.catalog.polaris-default.warehouse=polaris-default \
--conf spark.sql.catalog.polaris-default.oauth2-server-uri=http://polaris.polaris:8181/api/catalog/v1/oauth/tokens\
--conf spark.sql.catalog.polaris-default.credential=root:s3cr3t \
--conf spark.sql.catalog.polaris-default.scope=PRINCIPAL_ROLE:ALL \
--conf spark.sql.catalog.polaris-default.token-refresh-enabled=true \
--conf spark.sql.catalog.polaris-default.header.X-Iceberg-Access-Delegation=vended-credentials

```

- From REST + S3 template
```yaml
oauth2-server-uri: http://polaris.polaris:8181/api/catalog/v1/oauth/tokens
credential: root:s3cr3t
scope: PRINCIPAL_ROLE:ALL
token-refresh-enabled: true
header.X-Iceberg-Access-Delegation: vended-credentials
```