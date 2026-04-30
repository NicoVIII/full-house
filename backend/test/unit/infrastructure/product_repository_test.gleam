import application/page_limit
import application/page_offset
import application/ports/products/create as create_product_port
import application/ports/products/delete as delete_product_port
import application/ports/products/deletion_references as deletion_references_port
import application/ports/products/list as list_product_port
import application/ports/products/validate_parent_product as validate_parent_product_port
import domain/basics/uuid
import domain/product
import domain/product_deletion_references
import domain/product_name
import domain/validated_parent_product_id
import gleam/list
import gleam/option.{None, Some}
import infrastructure/product_repository/sqlite_product_repository/create_port as create_adapter
import infrastructure/product_repository/sqlite_product_repository/delete_port as delete_adapter
import infrastructure/product_repository/sqlite_product_repository/deletion_references_port as deletion_references_adapter
import infrastructure/product_repository/sqlite_product_repository/list_port as list_adapter
import infrastructure/product_repository/sqlite_product_repository/validate_parent_product_port as validate_parent_adapter
import sqlight

fn setup_in_memory_database() -> sqlight.Connection {
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

pub fn list_adapter_returns_paginated_products_test() {
  let connection = setup_in_memory_database()
  let repo = list_adapter.new(connection)

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

pub fn list_adapter_keeps_parent_relationship_test() {
  let connection = setup_in_memory_database()
  let repo = list_adapter.new(connection)

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

pub fn create_and_list_adapters_create_product_test() {
  let connection = setup_in_memory_database()
  let create_repo = create_adapter.new(connection)
  let list_repo = list_adapter.new(connection)

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

pub fn create_adapter_returns_parent_not_found_on_create_test() {
  let connection = setup_in_memory_database()
  let repo = create_adapter.new(connection)

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

pub fn list_adapter_skips_empty_name_rows_test() {
  let connection = setup_in_memory_database()
  let assert Ok(_) =
    sqlight.exec(
      "insert into products (id, name, parent_product_id) values ('018f4e1a-0000-7000-8000-000000000010', '   ', null)",
      on: connection,
    )
  let repo = list_adapter.new(connection)

  let assert Ok(result) =
    repo.list(list_product_port.Params(
      offset: page_offset.default(),
      limit: page_limit.new_exn(10),
    ))

  assert result.total == 3
  assert list.length(result.items) == 3
}

pub fn delete_adapter_deletes_unreferenced_product_test() {
  let connection = setup_in_memory_database()
  let repo = delete_adapter.new(connection)

  let deletable_product_id =
    product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000003"))

  let assert Ok(Nil) = repo.delete(deletable_product_id)
}

pub fn delete_adapter_returns_not_found_for_unknown_product_test() {
  let connection = setup_in_memory_database()
  let repo = delete_adapter.new(connection)

  let missing_product_id =
    product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-0000000000ff"))

  assert repo.delete(missing_product_id)
    == Error(delete_product_port.ProductNotFound)
}

pub fn delete_adapter_returns_stock_blocker_test() {
  let connection = setup_in_memory_database()
  let repo = delete_adapter.new(connection)

  let blocked_product_id =
    product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000001"))

  assert repo.delete(blocked_product_id)
    == Error(delete_product_port.ProductStillReferenced)
}

pub fn delete_adapter_returns_child_blocker_test() {
  let connection = setup_in_memory_database()
  let repo = delete_adapter.new(connection)

  let blocked_product_id =
    product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000002"))

  assert repo.delete(blocked_product_id)
    == Error(delete_product_port.ProductStillReferenced)
}

pub fn deletion_references_adapter_loads_reference_value_object_test() {
  let connection = setup_in_memory_database()
  let repo = deletion_references_adapter.new(connection)

  let blocked_product_id =
    product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000002"))

  assert repo.load(blocked_product_id)
    == Ok(product_deletion_references.new_exn(0, 1))
}

pub fn deletion_references_adapter_returns_database_failure_on_query_error_test() {
  let assert Ok(connection) = sqlight.open(":memory:")
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)
  let repo = deletion_references_adapter.new(connection)

  let blocked_product_id =
    product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000002"))

  assert repo.load(blocked_product_id)
    == Error(deletion_references_port.DatabaseFailure)
}

pub fn validate_parent_adapter_accepts_none_parent_test() {
  let connection = setup_in_memory_database()
  let repo = validate_parent_adapter.new(connection)

  let result = repo.validate(None)

  assert result == Ok(validated_parent_product_id.new_exn(None))
}

pub fn validate_parent_adapter_validates_existing_parent_test() {
  let connection = setup_in_memory_database()
  let repo = validate_parent_adapter.new(connection)

  let existing_parent_id =
    Some(
      product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000001")),
    )

  let result = repo.validate(existing_parent_id)

  assert result == Ok(validated_parent_product_id.new_exn(existing_parent_id))
}

pub fn validate_parent_adapter_rejects_nonexistent_parent_test() {
  let connection = setup_in_memory_database()
  let repo = validate_parent_adapter.new(connection)

  let nonexistent_parent_id =
    Some(
      product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-0000000000ff")),
    )

  assert repo.validate(nonexistent_parent_id)
    == Error(validate_parent_product_port.ParentProductNotFound)
}

pub fn validate_parent_adapter_returns_database_failure_on_query_error_test() {
  let assert Ok(connection) = sqlight.open(":memory:")
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)
  let repo = validate_parent_adapter.new(connection)

  let parent_id =
    Some(
      product.ProductId(uuid.new_exn("018f4e1a-0000-7000-8000-000000000001")),
    )

  assert repo.validate(parent_id)
    == Error(validate_parent_product_port.DatabaseFailure)
}
