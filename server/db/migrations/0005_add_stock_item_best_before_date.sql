-- migrate:up
create table stock_items_new (
  id text primary key,
  product_id text not null references products(id),
  best_before_date text not null
);

insert into stock_items_new (id, product_id, best_before_date)
select id, product_id, '2050-01-01'
from stock_items;

drop table stock_items;
alter table stock_items_new rename to stock_items;

create index if not exists stock_items_product_id_idx
  on stock_items(product_id);

-- migrate:down
create table stock_items_old (
  id text primary key,
  product_id text not null references products(id)
);

insert into stock_items_old (id, product_id)
select id, product_id
from stock_items;

drop table stock_items;
alter table stock_items_old rename to stock_items;

create index if not exists stock_items_product_id_idx
  on stock_items(product_id);
