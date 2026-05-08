import application/commands/create_stock_item
import application/shared/infrastructure_error
import common/product_id
import common/uuid
import domain/stock_items/stock_item
import gleam/dynamic/decode
import sqlight

fn insert_stock_item(
  item: stock_item.T,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  let stock_item.StockItem(id:, product_id:) = item

  let query_result =
    sqlight.query(
      "
      INSERT INTO stock_items (id, product_id)
      VALUES (?, ?)
      ",
      on: connection,
      with: [
        sqlight.text(uuid.value(id)),
        sqlight.text(product_id.value(product_id)),
      ],
      expecting: decode.success(1),
    )

  case query_result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

pub fn new(connection: sqlight.Connection) -> create_stock_item.CreatePort {
  fn(item) { insert_stock_item(item, connection) }
}
