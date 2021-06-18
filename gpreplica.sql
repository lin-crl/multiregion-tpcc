-- Geopartitioned leaseholder
use tpcc;
show create order_line;

-- 150 warehouses in total
alter table public.order_line partition by range (ol_w_id) (
       PARTITION apnw values from (MINVALUE) to (10),
       PARTITION euwest values from (10) to (30),
       PARTITION uswest values from (30) to (60),
       PARTITION useast values from (60) to (MAXVALUE)
);

alter partition apnw of index order_line@*
    configure zone using
    num_replicas =3,
    constraints = '[+region=ap-northeast-2]';
alter partition uswest of index order_line@*
    configure zone using
    num_replicas =3,
    constraints = '[+region=us-west-2]';
alter partition useast of index order_line@*
    configure zone using
    num_replicas =3,
    constraints = '[+region=us-east-2]';
alter partition euwest of index order_line@*
    configure zone using
    num_replicas =3,
    constraints = '[+region=eu-west-2]';




