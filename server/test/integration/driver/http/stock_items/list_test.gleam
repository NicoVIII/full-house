import application/queries/common/paging
import application/queries/common/stock_item_query_model
import gleam/http
import gleam/string
import integration/driver/http/stock_items/common
import integration/driver/http/testsetup
import wisp/simulate

pub fn list_stock_items_returns_best_before_date_test() {
  let handler =
    testsetup.build_handler_with_list_stock_items_port(fn(paging_params) {
      Ok(paging.Response(
        data: [
          stock_item_query_model.StockItemQueryModel(
            product_id: "018f4e1a-0000-7000-8000-000000000001",
            product_name: "Espresso",
            best_before_date: "2026-08-20",
            quantity: 1,
          ),
          stock_item_query_model.StockItemQueryModel(
            product_id: "018f4e1a-0000-7000-8000-000000000001",
            product_name: "Espresso",
            best_before_date: "2026-09-20",
            quantity: 1,
          ),
        ],
        total: 2,
        paging_params: paging_params,
      ))
    })

  let request = common.request(http.Get, "/api/v1/stock_items?limit=2&offset=0")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"best_before_date\": \"2026-08-20\"")
  assert string.contains(body, "\"best_before_date\": \"2026-09-20\"")
  assert string.contains(body, "\"total\": 2")
}

pub fn list_stock_items_rejects_invalid_limit_test() {
  let handler =
    testsetup.build_handler_with_list_stock_items_port(fn(_) {
      panic as "port should not be called"
    })

  let request = common.request(http.Get, "/api/v1/stock_items?limit=abc")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
}
