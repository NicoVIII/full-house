import application/create_product
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

pub fn map_create_product_response(
  result: create_product.CreateProductResult,
) -> String {
  json.object([#("data", map_product(result.product))])
  |> json.to_string
}
