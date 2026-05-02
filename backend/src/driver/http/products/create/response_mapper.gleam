import application/queries/common/product_query_model
import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import driver/http/products/product_json
import gleam/json
import gleam/option.{None, Some}

pub fn map_product_without_children(p: product.T) -> json.Json {
  product_json.map_product_query_model(
    product_query_model.ProductQueryModel(
      id: product_id.value(p.id),
      name: product_name.value(p.name),
      parent_product_id: case p.parent_product_id {
        Some(id) -> Some(existing_product_id.value(id))
        None -> None
      },
      children_ids: [],
    ),
  )
}
