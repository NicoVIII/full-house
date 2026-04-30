import composition/http/products_route
import composition/http/stock_route
import driver/http/router
import envoy
import gleam/erlang/process
import mist
import sqlight
import wisp
import wisp/wisp_mist

fn database_path() -> String {
  case envoy.get("DATABASE_PATH") {
    Ok(path) -> path
    Error(_) -> "./data/full_house.db"
  }
}

pub fn main() -> Nil {
  wisp.configure_logger()

  let assert Ok(connection) = sqlight.open(database_path())
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)
  let products_handler = products_route.compose(connection)
  let stock_handler = stock_route.compose(connection)

  let routes = router.Routes(products: products_handler, stock: stock_handler)
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
