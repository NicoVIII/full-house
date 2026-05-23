import application/commands/delete_product
import infrastructure/adapter/commands/delete_product/deletion_properties_adapter
import integration/create
import integration/infrastructure/testdatabase

pub fn product_with_no_dependencies_test() {
  let connection = testdatabase.setup()
  let port = deletion_properties_adapter.new(connection)
  // Oat Latte: no children, no stock items
  let id = create.product_id("018f4e1a-0000-7000-8000-000000000003")

  let assert Ok(props) = port(id)

  assert props
    == delete_product.DeletionProperties(
      has_children: False,
      has_stock_items: False,
    )
}

pub fn product_with_children_test() {
  let connection = testdatabase.setup()
  let port = deletion_properties_adapter.new(connection)
  // Latte: parent of Oat Latte
  let id = create.product_id("018f4e1a-0000-7000-8000-000000000002")

  let assert Ok(props) = port(id)

  assert props.has_children == True
}

pub fn product_with_stock_items_test() {
  let connection = testdatabase.setup()
  let port = deletion_properties_adapter.new(connection)
  // Espresso: has a stock item
  let id = create.product_id("018f4e1a-0000-7000-8000-000000000001")

  let assert Ok(props) = port(id)

  assert props.has_stock_items == True
}
