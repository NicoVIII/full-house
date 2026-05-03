import composition
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
    Error(Nil) -> "./data/full_house.db"
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
    // TODO: replace secret key base with env var
    |> wisp_mist.handler("development_secret_key_base_do_not_use_in_prod")
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
