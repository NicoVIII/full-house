import application/commands/create_product
import driver/http/products/product_json
import gleam/json

pub fn map_create_product_response(
  result: create_product.CreateProductResult,
) -> String {
  json.object([#("data", product_json.map_product(result.product))])
  |> json.to_string
}
