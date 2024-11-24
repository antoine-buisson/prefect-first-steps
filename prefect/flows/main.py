from prefect import task, flow, get_run_logger, get_client
from prefect_dask.task_runners import DaskTaskRunner

from prefect.context import get_run_context

from pyspark.sql import SparkSession
from pyspark import SparkConf

import dask
import os
import re

import pandas as pd
import random

@task
def create_and_filter_df(flow_name: str, n_spark_executors: int) -> pd.DataFrame:
    
    task_run_name = get_run_context().task_run.name
    task_name = get_run_context().task.name
    logger = get_run_logger()
    logger.info(f"starting spark application {task_run_name}")
    
    conf = (
        SparkConf()
        .set("spark.app.name", task_name)
        .set("spark.master", f"k8s://{os.environ['KUBERNETES_SERVICE_HOST']}:{os.environ['KUBERNETES_SERVICE_PORT']}")
        .set("spark.kubernetes.namespace", "spark")
        .set("spark.kubernetes.container.image", "spark-custom:latest")
        .set("spark.kubernetes.container.image.pullPolicy", "Never")
        .set("spark.driver.host", os.environ['POD_IP'])
        .set("spark.kubernetes.executor.podNamePrefix", re.sub(r'[^a-z0-9-]', '-', task_run_name))
        .set("spark.executor.instances", n_spark_executors)
        .set("spark.extraListeners", "io.openlineage.spark.agent.OpenLineageSparkListener")
        .set("spark.openlineage.transport.type", "http")
        .set("spark.openlineage.transport.url", "http://marquez.marquez")
        .set("spark.openlineage.namespace", flow_name)
    )
    
    logger.debug(conf.toDebugString())
    
    spark: SparkSession = SparkSession.builder.config(conf=conf).getOrCreate()
    
    n = random.randint(5, 20)
    
    # Sample data for the columns
    countries = ["USA", "Canada", "Brazil", "UK", "Germany", "France", "China", "India", "Australia", "Japan"]
    continents = {
        "North America": ["USA", "Canada"],
        "South America": ["Brazil"],
        "Europe": ["UK", "Germany", "France"],
        "Asia": ["China", "India", "Japan"],
        "Oceania": ["Australia"]
    }
    
    # Generate random rows
    data = []
    for _ in range(n):
        country = random.choice(countries)
        continent = next(cont for cont, country_list in continents.items() if country in country_list)
        nb_citizens = random.randint(1000, 1000000)  # Random number of citizens
        data.append({"country": country, "nb_citizens": nb_citizens, "continent": continent})
    
    # Create and return the DataFrame
    ddf = spark.createDataFrame(pd.DataFrame(data))
    
    ddf_filtered = ddf.filter(ddf['nb_citizens'] > 100000)
    
    df = ddf_filtered.toPandas()

    spark.stop()

    return df 
    
@task
def aggregate(dfs: list[pd.DataFrame]) -> pd.DataFrame:
    return pd.concat(dfs)
    
cluster_class = 'dask_kubernetes.operator.KubeCluster'

cluster_kwargs = {
    'namespace': 'dask', 
    'custom_cluster_spec': 'daskcluster.yaml'
}

@flow(task_runner=DaskTaskRunner(
    cluster_class=cluster_class, 
    cluster_kwargs=cluster_kwargs
))
def my_flow(nb_dataframes: int, n_spark_executors: int):
    logger = get_run_logger()
    
    flow_name = get_run_context().flow.name
    
    dfs_futures = [create_and_filter_df.submit(flow_name, n_spark_executors) for i in range(nb_dataframes)]
    
    dfs = [df_future.result() for df_future in dfs_futures]
    
    df_merged = aggregate.submit(dfs).result()
    
    logger.info(df_merged)