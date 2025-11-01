import argparse
import logging
import sys
import os

from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import StreamTableEnvironment

def main():
    # Set up the Table Environment
    env = StreamExecutionEnvironment.get_execution_environment()    
    for jar in os.listdir(os.getcwd()):
        if jar.endswith(".jar"):
            env.add_jars("file://{}/{}".format(os.getcwd(), jar))
    table_env = StreamTableEnvironment.create(env)

    # Register the DataGen source table
    table_env.execute_sql("""
    CREATE TABLE datagen_source (
        id INT,
        name STRING
    ) WITH (
        'connector' = 'datagen',
        'rows-per-second' = '1',
        'fields.id.kind' = 'sequence',
        'fields.id.start' = '1',
        'fields.id.end' = '1000'
    )
    """)
    
    # Regular Iceberg catalog configuration
    table_env.execute_sql("""
    CREATE CATALOG polaris_default WITH (
        'type' = 'iceberg',
        'catalog-type' = 'rest',
        'io-impl' = 'org.apache.iceberg.aws.s3.S3FileIO',
        'uri' = 'http://polaris.localtest.me/api/catalog',
        'warehouse' = 'polaris-default',
        'rest.catalog.security' = 'OAUTH2',
        'rest.catalog.oauth2.server-uri' = 'http://polaris.localtest.me/api/catalog/v1/oauth/tokens',
        'rest.catalog.oauth2.credential' = 'root:s3cr3t',
        'rest.catalog.oauth2.scope' = 'PRINCIPAL_ROLE:ALL',
        'rest.catalog.oauth2.token-refresh-enabled' = 'true',
        'rest.catalog.vended-credentials-enabled' = 'true',
        'fs.native-s3.enabled' = 'true',
        's3.endpoint' = 'http://s3.minio.localtest.me',
        's3.region' = 'us-east-1',
        's3.path-style-access' = 'true',
        's3.access-key' = 'minioadmin',
        's3.secret-key' = 'minioadmin'
    )
    """)

    # Register the Iceberg sink table
    table_env.execute_sql(f"""
    CREATE TABLE `polaris_default`.`default`.`iceberg_sink` (
        id INT,
        name STRING
    )
    """)

    # Insert data from DataGen source to Iceberg sink
    table_env.execute_sql("""
    INSERT INTO `polaris_default`.`default`.`iceberg_sink`
    SELECT id, name FROM datagen_source
    """)

if __name__ == '__main__':
    logging.basicConfig(stream=sys.stdout, level=logging.INFO, format="%(message)s")

    parser = argparse.ArgumentParser()

    argv = sys.argv[1:]
    known_args, _ = parser.parse_known_args(argv)

    main()