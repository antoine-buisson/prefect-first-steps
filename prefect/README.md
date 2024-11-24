minikube start

eval $(minikube docker-env)

kubectl port-forward svc/prefect-server 4200:4200

prefect deploy -n main && prefect deployment run 'my-flow/main'