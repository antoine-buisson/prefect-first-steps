from prefect import task, flow 
from prefect_dask.task_runners import DaskTaskRunner

#print square of a number
@task 
def print_squares(element):
    square = element ** 2
    print(square)

#The flow that is going to call the tasks
#This function will be the entry point for our script
@flow(task_runner=DaskTaskRunner(cluster_class='dask_kubernetes.operator.KubeCluster', cluster_kwargs={'namespace': 'dask', 'n_workers': 5}))
def my_flow(elements):
    for element in elements:
        print_squares.submit(element)

if __name__ == "__main__":
    elements = [1, 2]
    my_flow(elements)
