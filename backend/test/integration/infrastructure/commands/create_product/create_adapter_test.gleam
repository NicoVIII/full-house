import application/shared/infrastructure_error
import gleam/option.{None, Some}
import infrastructure/adapter/commands/create_product/create_adapter
import integration/create
import integration/infrastructure/testdatabase

pub fn create_product_test() {
  let connection = testdatabase.setup()
  let create_port = create_adapter.new(connection)

  let new_product =
    create.product(
      id: "018f4e1a-0000-7000-8000-0000000000aa",
      name: "Mocha",
      parent_id: None,
    )

  let assert Ok(Nil) = create_port(new_product)
  // TODO: Read back the product to verify it was created correctly
}

pub fn duplication_test() {
  let connection = testdatabase.setup()
  let create_port = create_adapter.new(connection)

  let new_product =
    create.product(
      id: "018f4e1a-0000-7000-8000-000000000001",
      name: "Duplicate Espresso",
      parent_id: None,
    )

  // Attempt to create a product with an ID that already exists in the test database
  assert create_port(new_product) == Error(infrastructure_error.DatabaseFailure)
}

pub fn missing_parent_test() {
  let connection = testdatabase.setup()
  let create_port = create_adapter.new(connection)

  let new_product =
    create.product(
      id: "018f4e1a-0000-7000-8000-0000000000bb",
      name: "Mocha",
      parent_id: Some("018f4e1a-0000-7000-8000-000000000099"),
    )

  assert create_port(new_product) == Error(infrastructure_error.DatabaseFailure)
}
