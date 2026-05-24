import application/shared/infrastructure_error
import common/product_id
import common/uuid_v7
import domain/stock_items/best_before_date
import domain/stock_items/stock_item
import gleam/dynamic/decode
import sqlight

fn insert_stock_item(
  item: stock_item.T,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  let stock_item.StockItem(id:, product_id:, best_before_date:) = item

  let query_result =
    sqlight.query(
      "
      INSERT INTO stock_items (id, product_id, best_before_date)
      VALUES (?, ?, ?)
      ",
      on: connection,
      with: [
        sqlight.text(uuid_v7.to_value(id)),
        sqlight.text(product_id.to_value(product_id)),
        sqlight.text(best_before_date.to_value(best_before_date)),
      ],
      expecting: decode.success(1),
    )

  case query_result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

pub fn new(connection: sqlight.Connection) {
  fn(item) { insert_stock_item(item, connection) }
}
