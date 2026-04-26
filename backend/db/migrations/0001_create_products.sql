-- migrate:up
create table if not exists products (
  id text primary key,
  name text not null,
  parent_product_id text references products(id)
);

-- migrate:down
drop table if exists products;
