# Iceberg Query

## Context
Query Iceberg tables using the Trino engine, Polaris catalog and Garage Object Storage

## Setup
- Follow the polaris setup to [create the default catalog](../catalogs/polaris.md)
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
```
- Connect to trino
```sh
kubectl exec --stdin --tty -n trino trino-coordinator-//////////-////// -- trino
#>>> trino>
```

## Create data in Iceberg
```sql
CREATE SCHEMA IF NOT EXISTS 'polaris-default'.'cookbook';
CREATE SCHEMA IF NOT EXISTS 'polaris-default'.'cookbook.public';
CREATE TABLE IF NOT EXISTS 'polaris-default'.'cookbook.public'.people (id int, name string);
INSERT INTO "polaris-default"."cookbook.public".people (id, name) VALUES (1, 'Alice'), (2, 'Bob');
SELECT name FROM "polaris-default"."cookbook.public".people;
```

Clean data
```sql
DROP TABLE "polaris-default"."cookbook.public".people;
DROP SCHEMA "polaris-default"."cookbook.public";
DROP SCHEMA "polaris-default"."cookbook";
```