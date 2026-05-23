import application/commands/remove_stock_item
import application/shared/infrastructure_error
import composition
import gleam/http
import gleam/string
import integration/driver/http/testsetup
import wisp/simulate

fn prepare_handler(mock_port: remove_stock_item.RemovePort) {
  testsetup.build_handler(fn(ctx) {
    composition.AppContext(..ctx, remove_stock_item_port: mock_port)
  })
}

pub fn remove_stock_item_returns_200_with_updated_quantity_test() {
  let handler =
    prepare_handler(fn(_item_product_id, _item_best_before_date) {
      Ok(remove_stock_item.Removed(2))
    })

  let request =
    simulate.request(
      http.Delete,
      "/api/v1/stock_items/018f4e1a-0000-7000-8000-000000000001/2026-10-15",
    )
    |> simulate.header("Accept", "application/json")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(
    body,
    "\"product_id\": \"018f4e1a-0000-7000-8000-000000000001\"",
  )
  assert string.contains(body, "\"best_before_date\": \"2026-10-15\"")
  assert string.contains(body, "\"quantity\": 2")
}

pub fn remove_stock_item_invalid_product_id_returns_400_test() {
  let handler =
    prepare_handler(fn(_, _) { panic as "port should not be called" })

  let request =
    simulate.request(http.Delete, "/api/v1/stock_items/not-a-uuid/2026-10-15")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"message\":\"product id is invalid\"")
}

pub fn remove_stock_item_invalid_best_before_date_returns_400_test() {
  let handler =
    prepare_handler(fn(_, _) { panic as "port should not be called" })

  let request =
    simulate.request(
      http.Delete,
      "/api/v1/stock_items/018f4e1a-0000-7000-8000-000000000001/15-10-2026",
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"best_before_date must use format YYYY-MM-DD\"",
  )
}

pub fn remove_stock_item_not_found_returns_404_test() {
  let handler = prepare_handler(fn(_, _) { Ok(remove_stock_item.NotFound) })

  let request =
    simulate.request(
      http.Delete,
      "/api/v1/stock_items/018f4e1a-0000-7000-8000-000000000001/2026-10-15",
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 404
  assert string.contains(body, "\"message\":\"stock item not found\"")
}

pub fn remove_stock_item_infrastructure_error_returns_500_test() {
  let handler =
    prepare_handler(fn(_, _) { Error(infrastructure_error.DatabaseFailure) })

  let request =
    simulate.request(
      http.Delete,
      "/api/v1/stock_items/018f4e1a-0000-7000-8000-000000000001/2026-10-15",
    )

  let response = handler(request)

  assert response.status == 500
}
