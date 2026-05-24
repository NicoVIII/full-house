import gleam/http
import wisp
import wisp/simulate

pub const valid_product_id = "018f4e1a-0000-7000-8000-000000000001"

pub const missing_product_id = "018f4e1a-0000-7000-8000-000000000099"

pub fn request(method: http.Method, path: String) -> wisp.Request {
  simulate.request(method, path)
  |> simulate.header("Accept", "application/json")
}

pub fn json_request(method: http.Method, path: String) -> wisp.Request {
  request(method, path)
  |> simulate.header("Content-Type", "application/json")
}

pub fn remove_path(product_id: String, best_before_date: String) -> String {
  "/api/v1/stock_items/" <> product_id <> "/" <> best_before_date
}
