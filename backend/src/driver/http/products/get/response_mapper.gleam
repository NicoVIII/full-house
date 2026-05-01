import application/queries/ports/list_child_ids as list_child_ids_port
import domain/products/product
import driver/http/products/product_json
import gleam/json

pub fn map_get_product_response(
  product: product.T,
  child_ids_repo: list_child_ids_port.T,
) -> String {
  let child_ids = case child_ids_repo.load(product.id) {
    Ok(ids) -> ids
    Error(_) -> []
  }

  json.object([
    #("data", product_json.map_product_with_children(product, child_ids)),
  ])
  |> json.to_string
}
