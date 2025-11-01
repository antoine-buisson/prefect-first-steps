from pyflink.table import EnvironmentSettings, TableEnvironment

env_settings = EnvironmentSettings.in_streaming_mode()
table_env = TableEnvironment.create(env_settings)

table_env.execute_sql("""
    CREATE TABLE datagen (
        order_number TINYINT,
        price        TINYINT
    ) WITH (
        'connector' = 'datagen',
        'fields.order_number.kind'='random',
        'fields.order_number.min'='1',
        'fields.order_number.max'='50',
        'rows-per-second' = '10'
    )
""")
table_env.execute_sql("""
    CREATE TABLE print (
        order_number TINYINT,
        price        TINYINT
    ) WITH (
        'connector' = 'print'
    )
""")

table_env.execute_sql("INSERT INTO print SELECT * FROM datagen").wait()