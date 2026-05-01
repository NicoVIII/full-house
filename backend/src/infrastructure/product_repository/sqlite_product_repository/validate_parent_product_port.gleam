import application/commands/ports/validate_parent_product as validate_parent_product_port
import domain/products/creation/validated_parent_id as validated_parent_product_id
import domain/products/product
import gleam/option.{None, Some}
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn map_error(_: sqlight.Error) -> validate_parent_product_port.Error {
  validate_parent_product_port.DatabaseFailure
}

/// Check if a parent product exists in the database.
/// Returns Ok(ValidatedParentProductId) if parent is None or if parent_id points to an existing product.
/// Returns Error(ParentProductNotFound) if parent_id points to a non-existent product.
fn validate_parent(
  connection: sqlight.Connection,
  parent_id: option.Option(product.Id),
) -> Result(
  option.Option(validated_parent_product_id.T),
  validate_parent_product_port.Error,
) {
  case parent_id {
    None -> {
      // No parent is always valid
      Ok(None)
    }
    Some(product_id) -> {
      // Verify parent exists
      use count <- result.try(
        sqlight.query(
          "
          select count(*)
          from products
          where id = ?
          ",
          on: connection,
          with: [sqlight.text(shared.product_id_value(product_id))],
          expecting: shared.total_decoder(),
        )
        |> result.map_error(map_error),
      )

      let assert [total] = count

      case total == 0 {
        True -> Error(validate_parent_product_port.ParentProductNotFound)
        False -> Ok(Some(validated_parent_product_id.new(product_id)))
      }
    }
  }
}

pub fn new(connection: sqlight.Connection) -> validate_parent_product_port.T {
  validate_parent_product_port.T(validate: fn(parent_id) {
    validate_parent(connection, parent_id)
  })
}
