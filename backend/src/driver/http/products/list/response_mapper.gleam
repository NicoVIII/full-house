import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/product_query_model
import application/queries/list_products
import driver/http/products/product_json
import gleam/json

fn map_product_list(products: List(product_query_model.T)) -> json.Json {
  json.array(products, product_json.map_product_query_model)
}

pub fn map_list_products_response(
  result: list_products.ListProductsResult,
) -> String {
  let data_json = map_product_list(result.data)

  json.object([
    #("data", data_json),
    #("total", json.int(result.total)),
    #("limit", json.int(page_limit.value(result.limit))),
    #("offset", json.int(page_offset.value(result.offset))),
  ])
  |> json.to_string
}
