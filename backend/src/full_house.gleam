import composition
import driver/http/router as http_router
import driver/skir/router as skir_router
import driver/skir/setup
import envoy
import gleam/erlang/process
import gleam/int
import mist
import simplifile
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

fn static_dir() -> String {
  case envoy.get("STATIC_DIR") {
    Ok(dir) -> dir
    Error(Nil) -> "./static"
  }
}

fn serve_index(dir: String) -> wisp.Response {
  case simplifile.read(dir <> "/index.html") {
    Ok(html) -> wisp.html_response(html, 200)
    // nolint: thrown_away_error
    Error(_) -> wisp.internal_server_error()
  }
}

pub fn build_handler(
  app_context: composition.AppContext,
  server_name: setup.ServerName,
) -> fn(wisp.Request) -> wisp.Response {
  fn(request) {
    let dir = static_dir()
    use <- wisp.serve_static(request, under: "/", from: dir)
    case wisp.path_segments(request) {
      ["api", "skir", ..] ->
        skir_router.handle_rpc_message(request, server_name)
      ["api", "rest", ..] | ["api", ..] ->
        http_router.handle_api_request(request, app_context)
      _ -> serve_index(dir)
    }
  }
}

pub fn main() -> Nil {
  wisp.configure_logger()

  // Prepare database connection
  let assert Ok(connection) = sqlight.open(database_path())
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)

  let context = composition.compose_app_context(connection)

  // Start the SkirRPC server
  let rpc_service = setup.make_service()
  let server_name = process.new_name("skir_rpc_server")
  let _server_pid =
    process.spawn(fn() {
      setup.start_server_loop(
        server_name,
        setup.ServerState(service: rpc_service, context:),
      )
    })

  let assert Ok(_) =
    context
    |> build_handler(server_name)
    |> wisp_mist.handler(secret_key_base())
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(port())
    |> mist.start

  process.sleep_forever()
}
