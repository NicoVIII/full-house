import application/list_products
import application/page_limit
import application/page_offset
import domain/basics/uuid
import domain/product
import domain/product_name
import gleam/json
import gleam/option.{None, Some}

fn map_product(p: product.T) -> json.Json {
  let product.ProductId(uid) = p.id
  let parent_id_json = case p.parent_product_id {
    None -> json.null()
    Some(product.ProductId(parent_uid)) -> json.string(uuid.value(parent_uid))
  }

  json.object([
    #("id", json.string(uuid.value(uid))),
    #("name", json.string(product_name.value(p.name))),
    #("parent_product_id", parent_id_json),
  ])
}

fn map_product_list(products: List(product.T)) -> json.Json {
  json.array(products, map_product)
}

pub fn map_list_products_response(
  result: list_products.ListProductsResult,
) -> String {
  let data_json = map_product_list(result.data)

  json.object([
    #("data", data_json),
    #("total", json.int(result.total)),
    #("offset", json.int(page_offset.value(result.offset))),
    #("limit", json.int(page_limit.value(result.limit))),
  ])
  |> json.to_string
}
