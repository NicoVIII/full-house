import application/page_limit
import application/page_offset
import application/ports/stock_repository
import infrastructure/stock_repository/mock_stock_repository

pub fn mock_stock_repository_returns_aggregated_quantities_test() {
  let repo = mock_stock_repository.new()
  let assert Ok(result) =
    repo.list(stock_repository.ListParams(
      offset: page_offset.default(),
      limit: page_limit.new_exn(10),
    ))

  let assert [first, ..] = result.items
  let stock_repository.StockSummary(product_name:, quantity:, ..) = first

  assert result.total == 5
  assert product_name == "Espresso"
  assert quantity == 4
}

pub fn mock_stock_repository_supports_pagination_test() {
  let repo = mock_stock_repository.new()
  let assert Ok(result) =
    repo.list(stock_repository.ListParams(
      offset: page_offset.new_exn(1),
      limit: page_limit.new_exn(2),
    ))

  let assert [first, second] = result.items
  let stock_repository.StockSummary(product_name: first_name, ..) = first
  let stock_repository.StockSummary(product_name: second_name, ..) = second

  assert result.total == 5
  assert first_name == "Cappuccino"
  assert second_name == "Latte"
}
