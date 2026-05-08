import common/product_id
import common/uuid
import domain/stock_items/stock_item
import gleam/json

pub fn map_stock_item(item: stock_item.T) -> json.Json {
  let stock_item.StockItem(id:, product_id:) = item
  json.object([
    #("id", json.string(uuid.value(id))),
    #("product_id", json.string(product_id.value(product_id))),
  ])
}
