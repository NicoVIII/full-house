import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/paging
import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/option.{type Option}

pub fn page_limit(raw: Int) -> page_limit.T {
  let assert Ok(limit) = page_limit.new(raw)
  limit
}

pub fn page_offset(raw: Int) -> page_offset.T {
  let assert Ok(offset) = page_offset.new(raw)
  offset
}

pub fn paging_params(limit: Int, offset: Int) -> paging.Params {
  paging.Params(limit: page_limit(limit), offset: page_offset(offset))
}

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
