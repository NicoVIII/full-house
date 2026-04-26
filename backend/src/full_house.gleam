import driver/http/products/handler as products_handler
import driver/http/router
import driver/http/stock/handler as stock_handler
import gleam/erlang/process
import infrastructure/product_repository/mock_product_repository
import infrastructure/stock_repository/mock_stock_repository
import mist
import wisp
import wisp/wisp_mist

fn products_route(request: wisp.Request) -> wisp.Response {
  let repo = mock_product_repository.new()
  products_handler.handle(request, repo)
}

fn stock_route(request: wisp.Request) -> wisp.Response {
  let repo = mock_stock_repository.new()
  stock_handler.handle(request, repo)
}

pub fn main() -> Nil {
  wisp.configure_logger()

  let routes = router.Routes(products: products_route, stock: stock_route)
  let handler = fn(request) { router.handle_request(request, routes) }

  let assert Ok(_) =
    handler
    // TODO: replace secret key base with env var
    |> wisp_mist.handler("development_secret_key_base_do_not_use_in_prod")
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
