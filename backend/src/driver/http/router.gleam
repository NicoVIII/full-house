import wisp

pub type Routes {
  Routes(
    products: fn(wisp.Request) -> wisp.Response,
    stock: fn(wisp.Request) -> wisp.Response,
  )
}

pub fn handle_request(request: wisp.Request, routes: Routes) -> wisp.Response {
  case wisp.path_segments(request) {
    ["api", "v1", "products", ..] -> routes.products(request)
    ["api", "v1", "stock"] -> routes.stock(request)
    _ -> wisp.not_found()
  }
}
