import application/commands/update_product_barcodes
import application/shared/infrastructure_error
import common/product_id
import domain/products/barcode
import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result
import infrastructure/adapter/decoder
import sqlight

fn product_exists(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "SELECT EXISTS(SELECT 1 FROM products WHERE id = ?)",
      on: connection,
      with: [sqlight.text(product_id.value(id))],
      expecting: decoder.exists(),
    )

  case query_result {
    Ok([exists]) -> Ok(exists)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result format for product existence query"
  }
}

fn find_conflicting_product_name(
  id: product_id.T,
  product_barcode: barcode.T,
  connection: sqlight.Connection,
) -> Result(option.Option(String), infrastructure_error.T) {
  let name_decoder = decode.field(0, decode.string, decode.success)

  let query_result =
    sqlight.query(
      "
			SELECT p.name
			FROM product_barcodes pb
			INNER JOIN products p ON p.id = pb.product_id
			WHERE pb.barcode = ? AND pb.product_id <> ?
			LIMIT 1
			",
      on: connection,
      with: [
        sqlight.text(barcode.value(product_barcode)),
        sqlight.text(product_id.value(id)),
      ],
      expecting: name_decoder,
    )

  case query_result {
    Ok([name]) -> Ok(option.Some(name))
    Ok([]) -> Ok(option.None)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result format for barcode conflict query"
  }
}

fn remove_barcodes(
  id: product_id.T,
  barcodes: List(barcode.T),
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  barcodes
  |> list.try_map(fn(product_barcode) {
    sqlight.query(
      "
			DELETE FROM product_barcodes
			WHERE product_id = ? AND barcode = ?
			RETURNING 1
			",
      on: connection,
      with: [
        sqlight.text(product_id.value(id)),
        sqlight.text(barcode.value(product_barcode)),
      ],
      expecting: decode.success(1),
    )
    |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure })
  })
  |> result.map(fn(_) { Nil })
}

fn add_barcodes(
  id: product_id.T,
  barcodes: List(barcode.T),
  connection: sqlight.Connection,
) -> Result(Nil, update_product_barcodes.UpdateBarcodesPortError) {
  barcodes
  |> list.try_map(fn(product_barcode) {
    use conflict <- result.try(
      find_conflicting_product_name(id, product_barcode, connection)
      |> result.map_error(update_product_barcodes.PortInfrastructureError),
    )

    case conflict {
      option.Some(conflicting_name) ->
        Error(update_product_barcodes.PortBarcodeAssignedToAnotherProduct(
          conflicting_name,
        ))
      option.None -> {
        let query_result =
          sqlight.query(
            "
						INSERT INTO product_barcodes (product_id, barcode)
						VALUES (?, ?)
						ON CONFLICT(product_id, barcode) DO NOTHING
						RETURNING 1
						",
            on: connection,
            with: [
              sqlight.text(product_id.value(id)),
              sqlight.text(barcode.value(product_barcode)),
            ],
            expecting: decode.success(1),
          )

        case query_result {
          Ok(_) -> Ok(Nil)
          Error(_) ->
            Error(update_product_barcodes.PortInfrastructureError(
              infrastructure_error.DatabaseFailure,
            ))
        }
      }
    }
  })
  |> result.map(fn(_) { Nil })
}

fn update_product_barcodes(
  id: product_id.T,
  additions: List(barcode.T),
  removals: List(barcode.T),
  connection: sqlight.Connection,
) -> Result(Nil, update_product_barcodes.UpdateBarcodesPortError) {
  use _ <- result.try(
    sqlight.exec("BEGIN TRANSACTION", on: connection)
    |> result.map_error(fn(_) {
      update_product_barcodes.PortInfrastructureError(
        infrastructure_error.DatabaseFailure,
      )
    }),
  )

  let rollback = fn(error: update_product_barcodes.UpdateBarcodesPortError) {
    case sqlight.exec("ROLLBACK", on: connection) {
      Ok(_) -> Error(error)
      Error(_) ->
        Error(update_product_barcodes.PortInfrastructureError(
          infrastructure_error.DatabaseFailure,
        ))
    }
  }

  use exists <- result.try(
    product_exists(id, connection)
    |> result.map_error(update_product_barcodes.PortInfrastructureError),
  )

  case exists {
    False -> rollback(update_product_barcodes.PortProductNotFound)
    True ->
      case remove_barcodes(id, removals, connection) {
        Error(error) ->
          rollback(update_product_barcodes.PortInfrastructureError(error))
        Ok(_) ->
          case add_barcodes(id, additions, connection) {
            Error(error) -> rollback(error)
            Ok(_) ->
              sqlight.exec("COMMIT", on: connection)
              |> result.map(fn(_) { Nil })
              |> result.map_error(fn(_) {
                update_product_barcodes.PortInfrastructureError(
                  infrastructure_error.DatabaseFailure,
                )
              })
          }
      }
  }
}

pub fn new(
  connection: sqlight.Connection,
) -> update_product_barcodes.UpdateBarcodesPort {
  fn(id, additions, removals) {
    update_product_barcodes(id, additions, removals, connection)
  }
}
