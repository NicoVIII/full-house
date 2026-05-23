CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE products (
  id text primary key,
  name text not null,
  parent_product_id text references products(id)
);
CREATE TRIGGER products_name_not_empty_on_insert
before insert on products
for each row
when trim(new.name) = ''
begin
  select raise(fail, 'products.name must not be empty');
end;
CREATE TRIGGER products_name_not_empty_on_update
before update of name on products
for each row
when trim(new.name) = ''
begin
  select raise(fail, 'products.name must not be empty');
end;
CREATE INDEX idx_products_parent_id ON products(parent_product_id);
CREATE TABLE IF NOT EXISTS "stock_items" (
  id text primary key,
  product_id text not null references products(id),
  best_before_date text not null
);
CREATE INDEX stock_items_product_id_idx
  on stock_items(product_id);
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('0001'),
  ('0002'),
  ('0003'),
  ('0004'),
  ('0005');
