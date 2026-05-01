import application/queries/list_products
import application/queries/page_limit
import application/queries/page_offset
import application/queries/ports/list_child_ids as list_child_ids_port
import domain/products/product
import driver/http/products/product_json
import gleam/json

fn map_product_with_children(
  child_ids_repo: list_child_ids_port.T,
  p: product.T,
) -> json.Json {
  let child_ids = case child_ids_repo.load(p.id) {
    Ok(ids) -> ids
    Error(_) -> []
  }

  product_json.map_product_with_children(p, child_ids)
}

fn map_product_list(
  child_ids_repo: list_child_ids_port.T,
  products: List(product.T),
) -> json.Json {
  json.array(products, fn(p) { map_product_with_children(child_ids_repo, p) })
}

pub fn map_list_products_response(
  result: list_products.ListProductsResult,
  child_ids_repo: list_child_ids_port.T,
) -> String {
  let data_json = map_product_list(child_ids_repo, result.data)

  json.object([
    #("data", data_json),
    #("total", json.int(result.total)),
    #("offset", json.int(page_offset.value(result.offset))),
    #("limit", json.int(page_limit.value(result.limit))),
  ])
  |> json.to_string
}
