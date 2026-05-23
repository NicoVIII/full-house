import application/commands/remove_stock_item
import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/best_before_date
import gleam/dynamic/decode
import gleam/result
import infrastructure/adapter/decoder
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
        sqlight.text(product_id.value(item_product_id)),
        sqlight.text(best_before_date.value(item_best_before_date)),
      ],
      expecting: deleted_row_decoder(),
    )

  case query_result {
    Ok([]) -> Ok(False)
    Ok(_) -> Ok(True)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

fn query_remaining_quantity(
  item_product_id: product_id.T,
  item_best_before_date: best_before_date.T,
  connection: sqlight.Connection,
) -> Result(Int, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT count(*)
      FROM stock_items
      WHERE product_id = ?
        AND best_before_date = ?
      ",
      on: connection,
      with: [
        sqlight.text(product_id.value(item_product_id)),
        sqlight.text(best_before_date.value(item_best_before_date)),
      ],
      expecting: decoder.count(),
    )

  case query_result {
    Ok([remaining_quantity]) -> Ok(remaining_quantity)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result format for stock_items count query"
  }
}

fn remove_stock_item(
  item_product_id: product_id.T,
  item_best_before_date: best_before_date.T,
  connection: sqlight.Connection,
) -> Result(remove_stock_item.RemoveOutcome, infrastructure_error.T) {
  use removed <- result.try(remove_one(
    item_product_id,
    item_best_before_date,
    connection,
  ))

  case removed {
    False -> Ok(remove_stock_item.NotFound)
    True -> {
      use remaining_quantity <- result.try(query_remaining_quantity(
        item_product_id,
        item_best_before_date,
        connection,
      ))
      Ok(remove_stock_item.Removed(remaining_quantity))
    }
  }
}

pub fn new(connection: sqlight.Connection) -> remove_stock_item.RemovePort {
  fn(item_product_id, item_best_before_date) {
    remove_stock_item(item_product_id, item_best_before_date, connection)
  }
}
