import application/commands/delete_product
import domain/products/product_name
import infrastructure/adapter/commands/delete_product/load_product_adapter
import integration/create
import integration/infrastructure/testdatabase

pub fn load_existing_product_test() {
  let connection = testdatabase.setup()
  let load_port = load_product_adapter.new(connection)
  let id = create.product_id("018f4e1a-0000-7000-8000-000000000001")

  let assert Ok(product) = load_port(id)

  assert product_name.value(product.name) == "Espresso"
}

pub fn load_nonexistent_product_test() {
  let connection = testdatabase.setup()
  let load_port = load_product_adapter.new(connection)
  let id = create.product_id("018f4e1a-0000-7000-8000-999999999999")

  assert load_port(id) == Error(delete_product.LoadProductNotFound)
}
