# Apache Trino

## Test in cluster
```sh
kubectl exec --stdin --tty -n trino trino-coordinator-//////////-////// -- trino 
#>>> trino> SHOW CATALOGS;
#>>>  Catalog 
#>>> ---------
#>>>  polaris 
#>>>  system  
#>>>  tpcds   
#>>>  tpch    
#>>> (4 rows)
```