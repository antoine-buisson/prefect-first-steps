from prefect import task, flow, get_run_logger
from prefect_dask.task_runners import DaskTaskRunner

#print square of a number
@task 
def compute_squares(element: int):
    logger = get_run_logger()
    result = element ** 2
    logger.info(result)
    return result

@task
def sum_squares(elements: list):
    logger = get_run_logger()
    result = sum(elements)
    logger.info(result)

#The flow that is going to call the tasks
#This function will be the entry point for our script
@flow(task_runner=DaskTaskRunner(cluster_class='dask_kubernetes.operator.KubeCluster', cluster_kwargs={'image': 'daskdev/dask:latest-py3.11', 'namespace': 'dask', 'n_workers': 1, 'env': {'EXTRA_PIP_PACKAGES': 'prefect prefect-dask dask-kubernetes'}}))
def my_flow(elements):
    sum_squares([compute_squares.submit(element).result() for element in elements])