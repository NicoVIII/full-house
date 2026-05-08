import common/product_id
import common/uuid
import domain/stock_items/stock_item
import driver/http/skir
import driver/http/wire_format
import driver/skirout/stock as skir_stock
import wisp

fn map_stock_item(item: stock_item.T) -> skir_stock.StockItem {
  let stock_item.StockItem(id:, product_id:) = item
  skir_stock.stock_item_new(uuid.value(id), product_id.value(product_id))
}

pub fn encode_stock_item(
  response response: wisp.Response,
  item item: stock_item.T,
  format format: wire_format.T,
) -> wisp.Response {
  response
  |> skir.encode(
    map_stock_item(item),
    skir_stock.stock_item_serializer(),
    format,
  )
}
