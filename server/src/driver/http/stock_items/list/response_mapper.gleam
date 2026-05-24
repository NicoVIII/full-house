import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/stock_item_query_model
import application/queries/list_stock_items
import driver/http/skir
import driver/http/wire_format
import driver/skirout/stock_items/queries
import gleam/list
import wisp

fn to_skir(summary: stock_item_query_model.T) -> queries.StockSummary {
  let stock_item_query_model.StockItemQueryModel(
    product_id:,
    product_name:,
    best_before_date:,
    quantity:,
  ) = summary
  queries.stock_summary_new(
    best_before_date,
    product_id,
    product_name,
    quantity,
  )
}

pub fn map_list_stock_response(
  response response: wisp.Response,
  list list_response: list_stock_items.Response,
  format format: wire_format.T,
) -> wisp.Response {
  let list_response =
    queries.stock_item_list_new(
      list.map(list_response.data, to_skir),
      page_limit.value(list_response.paging_params.limit),
      page_offset.value(list_response.paging_params.offset),
      list_response.total,
    )
  response
  |> skir.encode(list_response, queries.stock_item_list_serializer(), format)
}
