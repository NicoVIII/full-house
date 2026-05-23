import application/queries/common/paging
import application/queries/common/stock_item_query_model
import application/shared/infrastructure_error

pub type Response =
  paging.Response(stock_item_query_model.T)

pub type ListStockItemsPort =
  fn(paging.Params) -> Result(Response, infrastructure_error.T)

pub fn execute(
  paging paging_params: paging.Params,
  port list_stock_items: ListStockItemsPort,
) -> Result(Response, infrastructure_error.T) {
  list_stock_items(paging_params)
}
