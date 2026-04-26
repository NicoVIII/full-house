import application/page_limit
import application/page_offset
import application/ports/product_repository
import domain/product
import gleam/option.{None}
import infrastructure/product_repository/sqlite_product_repository
import sqlight

fn setup_in_memory_database() -> sqlight.Connection {
  let assert Ok(connection) = sqlight.open(":memory:")
  let assert Ok(_) =
    sqlight.exec(
      "
      create table products (
        id text primary key,
        name text not null,
        parent_product_id text references products(id)
      );

      insert into products (id, name, parent_product_id) values
        ('018f4e1a-0000-7000-8000-000000000001', 'Espresso', null),
        ('018f4e1a-0000-7000-8000-000000000002', 'Latte', null),
        ('018f4e1a-0000-7000-8000-000000000003', 'Oat Latte', '018f4e1a-0000-7000-8000-000000000002');
      ",
      on: connection,
    )

  connection
}

pub fn sqlite_product_repository_returns_paginated_products_test() {
  let connection = setup_in_memory_database()
  let repo = sqlite_product_repository.new(connection)

  let assert Ok(result) =
    repo.list(product_repository.ListParams(
      offset: page_offset.default(),
      limit: page_limit.new_exn(2),
    ))

  let assert [first, second] = result.items
  let product.Product(name: first_name, ..) = first
  let product.Product(name: second_name, ..) = second

  assert result.total == 3
  assert first_name == "Espresso"
  assert second_name == "Latte"
}

pub fn sqlite_product_repository_keeps_parent_relationship_test() {
  let connection = setup_in_memory_database()
  let repo = sqlite_product_repository.new(connection)

  let assert Ok(result) =
    repo.list(product_repository.ListParams(
      offset: page_offset.new_exn(2),
      limit: page_limit.new_exn(1),
    ))

  let assert [child] = result.items
  let product.Product(name:, parent_product_id:, ..) = child

  assert name == "Oat Latte"
  assert parent_product_id != None
}
