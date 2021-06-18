
-- Geopartitioned leaseholder
use tpcc;
show create customer;

alter table public.customer partition by range (c_w_id) (
       PARTITION apnw values from (MINVALUE) to (15),
       PARTITION euwest values from (15) to (30),
       PARTITION uswest values from (30) to (60),
       PARTITION useast values from (60) to (MAXVALUE)
);
alter index public.customer@customer_idx partition by range (c_w_id) (
       PARTITION apnw values from (MINVALUE) to (15),
       PARTITION euwest values from (15) to (30),
       PARTITION uswest values from (30) to (60),
       PARTITION useast values from (60) to (MAXVALUE)
);

alter partition apnw of index customer@*
    configure zone using
    num_replicas =5,
    constraints = '{"+region=ap-northeast-2":1}',
    lease_preferences = '[[+region=ap-northeast-2]]';
alter partition uswest of index customer@*
    configure zone using
    num_replicas =5,
    constraints = '{"+region=us-west-2":1}',
    lease_preferences = '[[+region=us-west-2]]';
alter partition useast of index customer@*
    configure zone using
    num_replicas =5,
    constraints = '{"+region=us-east-2":1}',
    lease_preferences = '[[+region=us-east-2]]';
alter partition euwest of index customer@*
    configure zone using
    num_replicas =5,
    constraints = '{"+region=eu-west-2":1}',
    lease_preferences = '[[+region=eu-west-2]]';





