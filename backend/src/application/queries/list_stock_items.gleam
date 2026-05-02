import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/stock_item_query_model
import application/shared/infrastructure_error

pub type ListStockItemsResult {
  ListStockItemsResult(
    data: List(stock_item_query_model.T),
    total: Int,
    offset: page_offset.T,
    limit: page_limit.T,
  )
}

pub type ListStockItemsPort =
  fn(page_limit.T, page_offset.T) ->
    Result(ListStockItemsResult, infrastructure_error.T)

pub fn execute(
  limit: page_limit.T,
  offset: page_offset.T,
  list_stock_items: ListStockItemsPort,
) -> Result(ListStockItemsResult, infrastructure_error.T) {
  list_stock_items(limit, offset)
}
