-- migrate:up
create trigger if not exists products_name_not_empty_on_insert
before insert on products
for each row
when trim(new.name) = ''
begin
  select raise(fail, 'products.name must not be empty');
end;

create trigger if not exists products_name_not_empty_on_update
before update of name on products
for each row
when trim(new.name) = ''
begin
  select raise(fail, 'products.name must not be empty');
end;

-- migrate:down
drop trigger if exists products_name_not_empty_on_update;
drop trigger if exists products_name_not_empty_on_insert;
