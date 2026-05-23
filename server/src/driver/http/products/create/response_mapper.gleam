import application/queries/common/product_query_model
import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import driver/http/products/skir
import driver/http/wire_format
import gleam/option.{None, Some}
import wisp

pub fn encode_product_without_children(
  response: wisp.Response,
  p: product.T,
  format: wire_format.T,
) -> wisp.Response {
  skir.encode_product(
    response,
    product_query_model.ProductQueryModel(
      id: product_id.value(p.id),
      name: product_name.value(p.name),
      parent_product_id: case p.parent_product_id {
        Some(id) -> Some(existing_product_id.value(id))
        None -> None
      },
      children_ids: [],
    ),
    format,
  )
}
