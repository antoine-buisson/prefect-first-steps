# Iceberg Query

## Context
Query Iceberg tables using the Trino engine, Polaris catalog and Garage Object Storage

## Setup
- Setup Minio bucket and key
- Create Polaris catalog
- Make sure Trino is correctly setup for this catalog
- Connect to trino
```sh
kubectl exec --stdin --tty -n trino trino-coordinator-//////////-////// -- trino
#>>> trino>
```

## Create data in Iceberg
```sql
CREATE SCHEMA IF NOT EXISTS "polaris-default"."cookbook";
CREATE TABLE IF NOT EXISTS "polaris-default"."cookbook".people (id INTEGER, name VARCHAR);
INSERT INTO "polaris-default"."cookbook".people (id, name) VALUES (1, 'Alice'), (2, 'Bob');
SELECT name FROM "polaris-default"."cookbook".people;
```

Clean data
```sql
DROP TABLE "polaris-default"."cookbook".people;
DROP SCHEMA "polaris-default"."cookbook";
```