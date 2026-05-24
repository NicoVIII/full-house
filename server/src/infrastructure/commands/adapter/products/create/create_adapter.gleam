import application/commands/products/create/ports
import application/shared/infrastructure_error
import domain/products/product
import gleam/dynamic/decode
import gleam/list
import gleam/result
import sqlight

fn create_product_row(
  snapshot: product.Snapshot,
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
        sqlight.text(snapshot.id),
        sqlight.text(snapshot.name),
        sqlight.nullable(sqlight.text, snapshot.parent_product_id),
      ],
      expecting: decode.success(1),
    )

  case query_result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

fn create_barcode_rows(
  snapshot: product.Snapshot,
  connection: sqlight.Connection,
) -> Result(Nil, ports.CreateError) {
  let name_decoder = decode.field(0, decode.string, decode.success)

  snapshot.barcodes
  |> list.try_map(fn(barcode) {
    sqlight.query(
      "
      INSERT INTO product_barcodes (product_id, barcode)
      VALUES (?, ?)
      ",
      on: connection,
      with: [
        sqlight.text(snapshot.id),
        sqlight.text(barcode),
      ],
      expecting: decode.success(1),
    )
    |> result.map_error(fn(_) {
      let query_result =
        sqlight.query(
          "
          SELECT p.name
          FROM product_barcodes pb
          INNER JOIN products p ON p.id = pb.product_id
          WHERE pb.barcode = ?
          LIMIT 1
          ",
          on: connection,
          with: [sqlight.text(barcode)],
          expecting: name_decoder,
        )

      case query_result {
        Ok([name]) -> ports.BarcodeAlreadyAssigned(name)
        Ok([]) ->
          ports.InfrastructureError(infrastructure_error.DatabaseFailure)
        Error(_) ->
          ports.InfrastructureError(infrastructure_error.DatabaseFailure)
        // nolint: avoid_panic
        Ok(_) -> panic as "Unexpected result format for barcode conflict query"
      }
    })
  })
  |> result.map(fn(_) { Nil })
}

fn create_product(
  product: product.T,
  connection: sqlight.Connection,
) -> Result(Nil, ports.CreateError) {
  use _ <- result.try(
    sqlight.exec("BEGIN TRANSACTION", on: connection)
    |> result.map_error(fn(_) {
      ports.InfrastructureError(infrastructure_error.DatabaseFailure)
    }),
  )

  let rollback = fn(error: ports.CreateError) {
    case sqlight.exec("ROLLBACK", on: connection) {
      Ok(_) -> Error(error)
      Error(_) ->
        Error(ports.InfrastructureError(infrastructure_error.DatabaseFailure))
    }
  }

  let product = product.to_snapshot(product)

  case create_product_row(product, connection) {
    Ok(_) ->
      case create_barcode_rows(product, connection) {
        Ok(_) ->
          sqlight.exec("COMMIT", on: connection)
          |> result.map_error(fn(_) {
            ports.InfrastructureError(infrastructure_error.DatabaseFailure)
          })
        Error(error) -> rollback(error)
      }
    Error(error) -> rollback(ports.InfrastructureError(error))
  }
}

pub fn new(connection: sqlight.Connection) {
  fn(product) { create_product(product, connection) }
}
