import application/queries/page_limit
import application/queries/page_offset
import application/queries/ports/stock_repository
import gleam/result

pub type ListStockResult {
  ListStockResult(
    data: List(stock_repository.StockSummary),
    total: Int,
    offset: page_offset.T,
    limit: page_limit.T,
  )
}

pub fn execute(
  repo: stock_repository.T,
  offset: page_offset.T,
  limit: page_limit.T,
) -> Result(ListStockResult, Nil) {
  use list_result <- result.try(
    repo.list(stock_repository.ListParams(offset: offset, limit: limit)),
  )

  Ok(ListStockResult(
    data: list_result.items,
    total: list_result.total,
    offset: offset,
    limit: limit,
  ))
}
