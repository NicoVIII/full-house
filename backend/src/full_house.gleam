import application/ports/product_repository
import application/ports/stock_repository
import driver/http/products/handler as products_handler
import driver/http/router
import driver/http/stock/handler as stock_handler
import envoy
import gleam/erlang/process
import infrastructure/product_repository/sqlite_product_repository
import infrastructure/stock_repository/sqlite_stock_repository
import mist
import sqlight
import wisp
import wisp/wisp_mist

fn products_route(
  request: wisp.Request,
  repo: product_repository.T,
) -> wisp.Response {
  products_handler.handle(request, repo)
}

fn stock_route(request: wisp.Request, repo: stock_repository.T) -> wisp.Response {
  stock_handler.handle(request, repo)
}

fn database_path() -> String {
  case envoy.get("DATABASE_PATH") {
    Ok(path) -> path
    Error(_) -> "./data/full_house.db"
  }
}

pub fn main() -> Nil {
  wisp.configure_logger()

  let assert Ok(connection) = sqlight.open(database_path())
  let product_repo = sqlite_product_repository.new(connection)
  let stock_repo = sqlite_stock_repository.new(connection)

  let routes =
    router.Routes(
      products: fn(request) { products_route(request, product_repo) },
      stock: fn(request) { stock_route(request, stock_repo) },
    )
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
