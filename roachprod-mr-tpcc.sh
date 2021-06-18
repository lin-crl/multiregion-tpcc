############################
# Standard Roachprod Demos
############################

export CLUSTER="${USER:0:6}-test"
export NODES=18
export CNODES=$(($NODES-1))
export VERSION=v20.2.11

### Create
#roachprod create ${CLUSTER} -n ${NODES} -c gce --gce-zones us-west2-a:5,us-east2-a:7,europe-central2-a:3,asia-northeast2-a:3
#roachprod create ${CLUSTER} -n ${NODES}  -c gce --geo
roachprod create ${CLUSTER} -n ${NODES}  -c aws --aws-zones us-east-2a:7,us-west-2a:5,eu-west-2b:3,ap-northeast-2a:3

roachprod stage ${CLUSTER} workload
roachprod stage ${CLUSTER} release ${VERSION}
roachprod start ${CLUSTER}

roachprod admin ${CLUSTER}:18 --open --ips
roachprod pgurl ${CLUSTER}:1

roachprod put ${CLUSTER}:1 *.sql

# init workload takes 35 minutes, this creates 4.5MM customer records
date
roachprod run ${CLUSTER}:1 -- "./cockroach workload init tpcc --warehouses=150 --db=tpcc"
date
# change schema
roachprod run ${CLUSTER}:1 "./cockroach sql --insecure < gpleaseholder.sql"
roachprod run ${CLUSTER}:1 "./cockroach sql --insecure < gpreplica.sql"
# wait for replication to complete
sleep 5m
# verify replica placement
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"SELECT start_key, lease_holder, lease_holder_locality, replicas
  FROM [SHOW RANGES FROM table tpcc.customer]
    WHERE start_key IS NOT NULL
    AND start_key NOT LIKE '%Prefix%' ORDER BY lease_holder;\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"SELECT start_key, lease_holder, lease_holder_locality, replicas
  FROM [SHOW RANGES FROM table tpcc.order_line]
    WHERE start_key IS NOT NULL
    AND start_key NOT LIKE '%Prefix%' ORDER BY lease_holder;\" "
# show us east and eu range and replication
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (0,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (10,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (20,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (30,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (40,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (50,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (60,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (70,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (80,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (90,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (100,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (110,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (120,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (130,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (140,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select replica_localities from [show range from table tpcc.order_line for row (149,1,3000,1)];\" "

# add load - not enough load -- some rows doesn't have results
#roachprod run ${CLUSTER}:2 -- './cockroach workload run tpcc --concurrency 32'

# update cluster setting
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"set cluster setting server.time_until_store_dead='2m0s'; \" "
# take down us-east region
roachprod stop ${CLUSTER}:1-7
# sleep for 1m for CRDB to consider them dead
sleep 120
# wait for it to stabilize
sleep 600
# verify how GP Replica table changes
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"SELECT start_key, lease_holder, lease_holder_locality, replicas
  FROM [SHOW RANGES FROM table tpcc.customer]
    WHERE start_key IS NOT NULL
    AND start_key NOT LIKE '%Prefix%' ORDER BY lease_holder;\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select start_key, replica_localities from [show range from table tpcc.order_line for row (0,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select start_key, replica_localities from [show range from table tpcc.order_line for row (10,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select start_key, replica_localities from [show range from table tpcc.order_line for row (20,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select start_key, replica_localities from [show range from table tpcc.order_line for row (30,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select start_key, replica_localities from [show range from table tpcc.order_line for row (40,1,3000,1)];\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"select start_key, replica_localities from [show range from table tpcc.order_line for row (59,1,3000,1)];\" "

# bring back us east
roachprod start ${CLUSTER}:1-7
sleep 600
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"SELECT start_key, lease_holder, lease_holder_locality, replicas
  FROM [SHOW RANGES FROM table tpcc.customer]
    WHERE start_key IS NOT NULL
    AND start_key NOT LIKE '%Prefix%' ORDER BY lease_holder;\" "
roachprod run ${CLUSTER}:18 -- "./cockroach sql --insecure --execute \"SELECT start_key, lease_holder, lease_holder_locality, replicas
  FROM [SHOW RANGES FROM table tpcc.order_line]
    WHERE start_key IS NOT NULL
    AND start_key NOT LIKE '%Prefix%' ORDER BY lease_holder;\" "


