import domain/products/deletable_product_id
import gleam/option.{None, Some}
import infrastructure/adapter/commands/delete_product/delete_adapter
import integration/create
import integration/infrastructure/testdatabase

pub fn delete_product_test() {
  let connection = testdatabase.setup()
  let delete_port = delete_adapter.new(connection)
  // Oat Latte: no children, no stock items — safe to delete
  let product =
    create.product(
      id: "018f4e1a-0000-7000-8000-000000000003",
      name: "Oat Latte",
      parent_id: Some("018f4e1a-0000-7000-8000-000000000002"),
    )
  let assert Ok(deletable_id) =
    deletable_product_id.prove(
      product: product,
      has_stock_items: False,
      has_children: False,
    )

  assert delete_port(deletable_id) == Ok(Nil)
}

pub fn delete_nonexistent_product_test() {
  let connection = testdatabase.setup()
  let delete_port = delete_adapter.new(connection)
  let product =
    create.product(
      id: "018f4e1a-0000-7000-8000-999999999999",
      name: "Ghost Product",
      parent_id: None,
    )
  let assert Ok(deletable_id) =
    deletable_product_id.prove(
      product: product,
      has_stock_items: False,
      has_children: False,
    )

  // DELETE with RETURNING returns an empty set; adapter does not verify row count
  assert delete_port(deletable_id) == Ok(Nil)
}
