# Garage

[DOCUMENTATION](https://garagehq.deuxfleurs.fr/documentation/quick-start)

## Check status 
Check that garage is healthy and get nodes ID
```sh
kubectl exec --stdin --tty -n garage garage-0 -- ./garage status
#>>> ==== HEALTHY NODES ====
#>>> ID           Hostname  Address           Tags  Zone  Capacity          DataAvail
#>>> <node_id_1>  garage-0  10.244.0.29:3901              NO ROLE ASSIGNED
#>>> ...
#>>> <node_id_n>  garage-1  10.244.0.30:3901              NO ROLE ASSIGNED
```

## Create a layout
For all nodes you want (<node_id_i>), assign region (-z) and storage size (-c)
```sh
kubectl exec --stdin --tty -n garage garage-0 -- ./garage layout assign -z garage -c 1G <node_id_i>
```
Observe the layout
```sh
kubectl exec --stdin --tty -n garage garage-0 -- ./garage layout show
#>>> ==== CURRENT CLUSTER LAYOUT ====
#>>> No nodes currently have a role in the cluster.
#>>> Current cluster layout version: 0
#>>> 
#>>> ==== STAGED ROLE CHANGES ====
#>>> ID                Tags  Zone    Capacity
#>>> <node_id_1>             garage  1000.0 MB
#>>> <node_id_2>             garage  1000.0 MB
#>>> 
#>>> ==== NEW CLUSTER LAYOUT AFTER APPLYING CHANGES ====
#>>> ID                Tags  Zone    Capacity   Usable capacity
#>>> <node_id_1>             garage  1000.0 MB  1000.0 MB (100.0%)
#>>> <node_id_2>             garage  1000.0 MB  1000.0 MB (100.0%)
#>>> 
#>>> Zone redundancy: maximum
#>>> 
#>>> ==== COMPUTATION OF A NEW PARTITION ASSIGNATION ====
#>>> 
#>>> Partitions are replicated 2 times on at least 1 distinct zones.
#>>> 
#>>> Optimal partition size:                     3.9 MB
#>>> Usable capacity / total cluster capacity:   2.0 GB / 2.0 GB (100.0 %)
#>>> Effective capacity (replication factor 2):  1000.0 MB
#>>> 
#>>> garage              Tags  Partitions        Capacity   Usable capacity
#>>>   <node_id_1>             256 (256 new)     1000.0 MB  1000.0 MB (100.0%)
#>>>   <node_id_2>             256 (256 new)     1000.0 MB  1000.0 MB (100.0%)
#>>>   TOTAL                   512 (256 unique)  2.0 GB     2.0 GB (100.0%)
```
Apply the layout
```sh
kubectl exec --stdin --tty -n garage garage-0 -- ./garage layout apply --version 1
#>>> ==== COMPUTATION OF A NEW PARTITION ASSIGNATION ====
#>>> 
#>>> Partitions are replicated 2 times on at least 1 distinct zones.
#>>> 
#>>> Optimal partition size:                     3.9 MB
#>>> Usable capacity / total cluster capacity:   2.0 GB / 2.0 GB (100.0 %)
#>>> Effective capacity (replication factor 2):  1000.0 MB
#>>> 
#>>> garage              Tags  Partitions        Capacity   Usable capacity
#>>>   <node_id_1>             256 (256 new)     1000.0 MB  1000.0 MB (100.0%)
#>>>   <node_id_2>             256 (256 new)     1000.0 MB  1000.0 MB (100.0%)
#>>>   TOTAL                   512 (256 unique)  2.0 GB     2.0 GB (100.0%)
```

## Generate API Key
```sh
# Create API Key and note credentials
kubectl exec --stdin --tty -n garage garage-0 -- ./garage key create my-api-key
```

## Generate Bucket and permissions
```sh
# Create Bucket
kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket create my-bucket

# Assign permissions to api key
kubectl exec --stdin --tty -n garage garage-0 -- ./garage bucket allow \
  --read \
  --write \
  --owner \
  my-bucket \
  --key my-api-key
```

## Test Connection
### Rclone
```toml
[garage]
type = s3
provider = Other
env_auth = false
access_key_id = Garage-Key-ID
secret_access_key = Garage-Secret-key
region = garage
endpoint = http://s3.garage.localtest.me
force_path_style = true
acl = private
bucket_acl = private
```
```sh
rclone lsd garage:
```

### awscli
```sh
export AWS_ACCESS_KEY_ID=Garage-Key-ID
export AWS_SECRET_ACCESS_KEY=Garage-Secret-key
export AWS_DEFAULT_REGION='garage'
export AWS_ENDPOINT_URL='http://s3.garage.localtest.me'

aws s3 ls
```