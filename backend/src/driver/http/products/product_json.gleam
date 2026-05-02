import application/queries/common/product_query_model
import gleam/json
import gleam/option.{None, Some}

pub fn map_product_query_model(p: product_query_model.T) -> json.Json {
  let parent_id_json = case p.parent_product_id {
    Some(id) -> json.string(id)
    None -> json.null()
  }

  json.object([
    #("id", json.string(p.id)),
    #("name", json.string(p.name)),
    #("parent_product_id", parent_id_json),
    #("child_product_ids", json.array(p.children_ids, json.string)),
  ])
}
