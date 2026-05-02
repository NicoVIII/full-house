import application/commands/create_product
import application/shared/infrastructure_error
import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/dynamic/decode
import sqlight

fn create_product(
  new_product: product.T,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  let product.T(id:, name:, parent_product_id:) = new_product

  let query_result =
    sqlight.query(
      "
      INSERT INTO products (id, name, parent_product_id)
      VALUES (?, ?, ?)
      ",
      on: connection,
      with: [
        sqlight.text(product_id.value(id)),
        sqlight.text(product_name.value(name)),
        sqlight.nullable(
          fn(product_id) { sqlight.text(existing_product_id.value(product_id)) },
          parent_product_id,
        ),
      ],
      expecting: decode.success(1),
    )

  case query_result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

pub fn new(connection: sqlight.Connection) -> create_product.CreatePort {
  fn(new_product) { create_product(new_product, connection) }
}
