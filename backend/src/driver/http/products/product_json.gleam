import domain/basics/uuid
import domain/products/product
import domain/products/product_name
import gleam/json
import gleam/option.{None, Some}

pub fn map_product(p: product.T) -> json.Json {
  map_product_with_children(p, [])
}

pub fn map_product_with_children(
  p: product.T,
  child_ids: List(String),
) -> json.Json {
  let product.ProductId(uid) = p.id
  let parent_id_json = case p.parent_product_id {
    None -> json.null()
    Some(product.ProductId(parent_uid)) -> json.string(uuid.value(parent_uid))
  }
  let child_ids_json = json.array(child_ids, json.string)

  json.object([
    #("id", json.string(uuid.value(uid))),
    #("name", json.string(product_name.value(p.name))),
    #("parent_product_id", parent_id_json),
    #("child_product_ids", child_ids_json),
  ])
}
