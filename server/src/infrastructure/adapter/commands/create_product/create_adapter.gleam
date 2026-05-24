import application/commands/create_product
import application/shared/infrastructure_error
import common/product_id
import domain/products/barcode
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result
import sqlight

fn create_product_row(
  id: product_id.T,
  name: product_name.T,
  parent_product_id: option.Option(existing_product_id.T),
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
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

fn create_barcode_rows(
  id: product_id.T,
  barcodes: List(barcode.T),
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  barcodes
  |> list.try_map(fn(code) {
    sqlight.query(
      "
      INSERT INTO product_barcodes (product_id, barcode)
      VALUES (?, ?)
      ",
      on: connection,
      with: [
        sqlight.text(product_id.value(id)),
        sqlight.text(barcode.value(code)),
      ],
      expecting: decode.success(1),
    )
    |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure })
  })
  |> result.map(fn(_) { Nil })
}

fn create_product(
  new_product: product.T,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  let product.T(id:, name:, parent_product_id:, barcodes:) = new_product

  use _ <- result.try(
    sqlight.exec("BEGIN TRANSACTION", on: connection)
    |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure }),
  )

  let rollback = fn(error: infrastructure_error.T) {
    case sqlight.exec("ROLLBACK", on: connection) {
      Ok(_) -> Error(error)
      Error(_) -> Error(infrastructure_error.DatabaseFailure)
    }
  }

  case create_product_row(id, name, parent_product_id, connection) {
    Ok(_) ->
      case create_barcode_rows(id, barcodes, connection) {
        Ok(_) ->
          sqlight.exec("COMMIT", on: connection)
          |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure })
        Error(error) -> rollback(error)
      }
    Error(error) -> rollback(error)
  }
}

pub fn new(connection: sqlight.Connection) -> create_product.CreatePort {
  fn(new_product) { create_product(new_product, connection) }
}
