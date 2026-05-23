import application/commands/remove_stock_item
import common/product_id
import domain/stock_items/best_before_date
import driver/http/skir
import driver/http/wire_format
import driver/skirout/stock as skir_stock
import wisp

fn map_response(
  response: remove_stock_item.Response,
) -> skir_stock.RemoveStockItemResponse {
  let remove_stock_item.Response(
    product_id: item_product_id,
    best_before_date: item_best_before_date,
    remaining_quantity:,
  ) = response

  skir_stock.remove_stock_item_response_new(
    best_before_date.value(item_best_before_date),
    product_id.value(item_product_id),
    remaining_quantity,
  )
}

pub fn encode_response(
  response response: wisp.Response,
  payload payload: remove_stock_item.Response,
  format format: wire_format.T,
) -> wisp.Response {
  response
  |> skir.encode(
    map_response(payload),
    skir_stock.remove_stock_item_response_serializer(),
    format,
  )
}
