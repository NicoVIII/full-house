import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/stock_item_query_model
import application/queries/list_stock_items
import gleam/json

fn map_stock_item(summary: stock_item_query_model.T) -> json.Json {
  let stock_item_query_model.StockItemQueryModel(
    product_id:,
    product_name:,
    quantity:,
  ) = summary
  json.object([
    #("product_id", json.string(product_id)),
    #("product_name", json.string(product_name)),
    #("quantity", json.int(quantity)),
  ])
}

fn map_stock_list(summaries: List(stock_item_query_model.T)) -> json.Json {
  json.array(summaries, map_stock_item)
}

pub fn map_list_stock_response(response: list_stock_items.Response) -> String {
  let data_json = map_stock_list(response.data)

  json.object([
    #("data", data_json),
    #("total", json.int(response.total)),
    #("offset", json.int(page_offset.value(response.paging_params.offset))),
    #("limit", json.int(page_limit.value(response.paging_params.limit))),
  ])
  |> json.to_string
}
