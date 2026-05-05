import composition
import driver/http/router
import envoy
import gleam/erlang/process
import gleam/int
import mist
import sqlight
import wisp
import wisp/wisp_mist

fn database_path() -> String {
  case envoy.get("DATABASE_PATH") {
    Ok(path) -> path
    Error(Nil) -> "./db/data/full_house.db"
  }
}

fn secret_key_base() -> String {
  case envoy.get("SECRET_KEY_BASE") {
    Ok(key) -> key
    Error(Nil) -> "development_secret_key_base_do_not_use_in_prod"
  }
}

fn port() -> Int {
  case envoy.get("PORT") {
    Ok(p) ->
      case int.parse(p) {
        Ok(n) -> n
        Error(Nil) -> 8000
      }
    Error(Nil) -> 8000
  }
}

pub fn build_handler(
  app_context: composition.AppContext,
) -> fn(wisp.Request) -> wisp.Response {
  fn(request) { router.handle_request(request, app_context) }
}

pub fn main() -> Nil {
  wisp.configure_logger()

  // Prepare database connection
  let assert Ok(connection) = sqlight.open(database_path())
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)

  let assert Ok(_) =
    composition.compose_app_context(connection)
    |> build_handler
    |> wisp_mist.handler(secret_key_base())
    |> mist.new
    |> mist.port(port())
    |> mist.start

  process.sleep_forever()
}
