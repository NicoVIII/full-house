import application/commands/stock_items/delete/ports
import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/best_before_date
import gleam/dynamic/decode
import gleam/result
import sqlight

fn deleted_row_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

fn remove_one(
  item_product_id: product_id.T,
  item_best_before_date: best_before_date.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      DELETE FROM stock_items
      WHERE id = (
        SELECT id
        FROM stock_items
        WHERE product_id = ?
          AND best_before_date = ?
        ORDER BY id
        LIMIT 1
      )
      RETURNING 1
      ",
      on: connection,
      with: [
        sqlight.text(product_id.to_value(item_product_id)),
        sqlight.text(best_before_date.to_value(item_best_before_date)),
      ],
      expecting: deleted_row_decoder(),
    )

  case query_result {
    Ok([]) -> Ok(False)
    Ok(_) -> Ok(True)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

fn remove_stock_item(
  item_product_id: product_id.T,
  item_best_before_date: best_before_date.T,
  connection: sqlight.Connection,
) -> Result(ports.DeleteOutcome, infrastructure_error.T) {
  use removed <- result.try(remove_one(
    item_product_id,
    item_best_before_date,
    connection,
  ))

  case removed {
    False -> ports.NotFound
    True -> ports.Deleted
  }
  |> Ok
}

pub fn new(connection: sqlight.Connection) {
  fn(item_product_id, item_best_before_date) {
    remove_stock_item(item_product_id, item_best_before_date, connection)
  }
}
