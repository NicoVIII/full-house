import application/queries/list_stock
import application/queries/page_limit
import application/queries/page_offset
import application/queries/ports/stock_repository
import domain/basics/uuid
import domain/products/product
import gleam/json

fn map_stock_summary(summary: stock_repository.StockSummary) -> json.Json {
  let stock_repository.StockSummary(product_id:, product_name:, quantity:) =
    summary
  let product.ProductId(uid) = product_id

  json.object([
    #("product_id", json.string(uuid.value(uid))),
    #("product_name", json.string(product_name)),
    #("quantity", json.int(quantity)),
  ])
}

fn map_stock_list(summaries: List(stock_repository.StockSummary)) -> json.Json {
  json.array(summaries, map_stock_summary)
}

pub fn map_list_stock_response(result: list_stock.ListStockResult) -> String {
  let data_json = map_stock_list(result.data)

  json.object([
    #("data", data_json),
    #("total", json.int(result.total)),
    #("offset", json.int(page_offset.value(result.offset))),
    #("limit", json.int(page_limit.value(result.limit))),
  ])
  |> json.to_string
}
