from prefect import flow, task, get_run_logger
from prefect.context import get_run_context
from kubernetes import client, config
from kubernetes.client import CustomObjectsApi
import time
import os

# Define the custom resource details
GROUP = "sparkoperator.k8s.io"  # API Group for the SparkApplication CRD
VERSION = "v1beta2"             # API Version
PLURAL = "sparkapplications"    # Plural name of the resource
NAMESPACE = "default"             # Namespace to deploy the resources

@task
def get_spark_app_spec(name: str, spark_app_file_path: str, n_executors: int):
    
    driver = {
        "cores": 1,
        "memory": "512m",
        "serviceAccount": "spark-operator-spark"
    }
    
    executor = {
        "instances": n_executors,
        "cores": 1,
        "memory": "512m"
    }
    
    spec = {
        "type": "Python",
        "pythonVersion": "3",
        "mode": "cluster",
        "image": os.getenv('SPARK_IMAGE'),
        "imagePullPolicy": "Never",
        "mainApplicationFile": f"local://{spark_app_file_path}",
        "sparkVersion": "3.5.0",
        "driver": driver,
        "executor": executor
    }
    
    spark_app = {
        "apiVersion": f"{GROUP}/{VERSION}",
        "kind": "SparkApplication",
        "metadata": {
            "name": name,
            "namespace": NAMESPACE
        },
        "spec": spec
    }
    
    return spark_app

@task
def deploy_spark_application(spark_app: dict):
    """
    Deploys a SparkApplication and monitors its status until completion.
    """
    logger = get_run_logger()
    
    # Load in-cluster configuration
    config.load_incluster_config()

    # Create an API client for custom resources
    api = client.CustomObjectsApi()

    # Create the SparkApplication
    try:
        name = spark_app.get('metadata').get('name')
        
        logger.info(f"Deploying SparkApplication: {name}...")
        api.create_namespaced_custom_object(
            group=GROUP,
            version=VERSION,
            namespace=NAMESPACE,
            plural=PLURAL,
            body=spark_app
        )
        logger.info(f"SparkApplication {name} created.")
    except client.exceptions.ApiException as e:
        logger.error(f"Exception when creating SparkApplication {name}: {e}")
        return False
    return True

@task
def monitor_spark_application(name: str):
    """
    Monitors the status of a SparkApplication until it reaches 'COMPLETED'.
    """
    logger = get_run_logger()
    
    # Load in-cluster configuration
    config.load_incluster_config()

    # Create an API client for custom resources
    api = client.CustomObjectsApi()
    
    logger.info(f"Monitoring SparkApplication {name} status...")
    
    while True:
        try:
            resource = api.get_namespaced_custom_object(
                group=GROUP,
                version=VERSION,
                namespace=NAMESPACE,
                plural=PLURAL,
                name=name
            )
            status = resource.get("status", {})
            application_state = status.get("applicationState", {}).get("state")

            logger.debug(f"SparkApplication {name} state: {application_state}")

            if application_state == "COMPLETED":
                logger.info(f"SparkApplication {name} has completed successfully.")
                break
            elif application_state in {"FAILED", "UNKNOWN"}:
                logger.warning(f"SparkApplication {name} ended with state: {application_state}")
                break

            time.sleep(5)

        except client.exceptions.ApiException as e:
            logger.error(f"Exception when checking SparkApplication {name} status: {e}")
            break

@flow
def spark_operator_test(spark_app_file_path: str, n_executors: int):
    
    app_name = get_run_context().flow_run.name
    
    spark_app_spec = get_spark_app_spec(name=app_name, spark_app_file_path=spark_app_file_path, n_executors=n_executors)
    
    if deploy_spark_application(spark_app_spec):
        monitor_spark_application(app_name)