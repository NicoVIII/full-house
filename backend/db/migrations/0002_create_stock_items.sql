-- migrate:up
create table if not exists stock_items (
  id text primary key,
  product_id text not null references products(id)
);

create index if not exists stock_items_product_id_idx
  on stock_items(product_id);

-- migrate:down
drop index if exists stock_items_product_id_idx;
drop table if exists stock_items;
