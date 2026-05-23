import sqlight

pub fn setup() -> sqlight.Connection {
  let assert Ok(connection) = sqlight.open(":memory:")
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)
  let assert Ok(_) =
    sqlight.exec(
      "
      create table products (
        id text primary key,
        name text not null,
        parent_product_id text references products(id)
      );

      create table stock_items (
        id text primary key,
        product_id text not null references products(id)
      );

      insert into products (id, name, parent_product_id) values
        ('018f4e1a-0000-7000-8000-000000000001', 'Espresso', null),
        ('018f4e1a-0000-7000-8000-000000000002', 'Latte', null),
        ('018f4e1a-0000-7000-8000-000000000003', 'Oat Latte', '018f4e1a-0000-7000-8000-000000000002');

      insert into stock_items (id, product_id) values
        ('018f4e1a-0000-7000-8000-0000000000f1', '018f4e1a-0000-7000-8000-000000000001');
      ",
      on: connection,
    )

  connection
}
