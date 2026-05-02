import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/option.{type Option}

pub fn product_id(raw: String) -> product_id.T {
  let assert Ok(id) = product_id.new(raw)
  id
}

pub fn product(
  id id_raw: String,
  name name_raw: String,
  parent_id parent_id_raw: Option(String),
) -> product.T {
  let id = product_id(id_raw)
  let assert Ok(name) = product_name.new(name_raw)
  let parent_id =
    option.map(parent_id_raw, fn(raw) {
      let assert Ok(id) =
        product_id(raw)
        |> existing_product_id.prove(True)
      id
    })

  product.T(id: id, name: name, parent_product_id: parent_id)
}
