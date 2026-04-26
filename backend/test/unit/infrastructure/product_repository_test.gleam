import application/page_limit
import application/page_offset
import application/ports/products/create as create_product_port
import application/ports/products/list as list_product_port
import domain/basics/uuid
import domain/product
import domain/product_name
import gleam/list
import gleam/option.{None, Some}
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
  let repo = sqlite_product_repository.list_port(connection)

  let assert Ok(result) =
    repo.list(list_product_port.Params(
      offset: page_offset.default(),
      limit: page_limit.new_exn(2),
    ))

  let assert [first, second] = result.items
  let product.Product(name: first_name, ..) = first
  let product.Product(name: second_name, ..) = second

  assert result.total == 3
  assert product_name.value(first_name) == "Espresso"
  assert product_name.value(second_name) == "Latte"
}

pub fn sqlite_product_repository_keeps_parent_relationship_test() {
  let connection = setup_in_memory_database()
  let repo = sqlite_product_repository.list_port(connection)

  let assert Ok(result) =
    repo.list(list_product_port.Params(
      offset: page_offset.new_exn(2),
      limit: page_limit.new_exn(1),
    ))

  let assert [child] = result.items
  let product.Product(name:, parent_product_id:, ..) = child

  assert product_name.value(name) == "Oat Latte"
  assert parent_product_id != None
}

pub fn sqlite_product_repository_creates_product_test() {
  let connection = setup_in_memory_database()
  let create_repo = sqlite_product_repository.create_port(connection)
  let list_repo = sqlite_product_repository.list_port(connection)

  let new_product =
    product.Product(
      id: product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-0000000000aa")),
      name: product_name.new_exn("Mocha"),
      parent_product_id: None,
    )

  let assert Ok(Nil) = create_repo.create(new_product)

  let assert Ok(list_result) =
    list_repo.list(list_product_port.Params(
      offset: page_offset.default(),
      limit: page_limit.new_exn(10),
    ))

  assert list_result.total == 4
  assert list_result.items
    |> list.any(fn(p) { product_name.value(p.name) == "Mocha" })
}

pub fn sqlite_product_repository_returns_parent_not_found_on_create_test() {
  let connection = setup_in_memory_database()
  let repo = sqlite_product_repository.create_port(connection)

  let new_product =
    product.Product(
      id: product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-0000000000bb")),
      name: product_name.new_exn("Mocha"),
      parent_product_id: Some(
        product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000099")),
      ),
    )

  assert repo.create(new_product)
    == Error(create_product_port.ParentProductNotFound)
}

pub fn sqlite_product_repository_skips_empty_name_rows_test() {
  let connection = setup_in_memory_database()
  let assert Ok(_) =
    sqlight.exec(
      "insert into products (id, name, parent_product_id) values ('018f4e1a-0000-7000-8000-000000000010', '   ', null)",
      on: connection,
    )
  let repo = sqlite_product_repository.list_port(connection)

  let assert Ok(result) =
    repo.list(list_product_port.Params(
      offset: page_offset.default(),
      limit: page_limit.new_exn(10),
    ))

  assert result.total == 3
  assert list.length(result.items) == 3
}
