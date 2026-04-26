import driver/http/stock/handler as stock_handler
import infrastructure/stock_repository/sqlite_stock_repository
import sqlight
import wisp

pub fn compose(
  connection: sqlight.Connection,
) -> fn(wisp.Request) -> wisp.Response {
  let stock_repo = sqlite_stock_repository.new(connection)

  fn(request) { stock_handler.handle(request, stock_repo) }
}
