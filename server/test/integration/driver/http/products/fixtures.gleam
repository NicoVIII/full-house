import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/paging
import application/queries/common/product_query_model
import application/queries/get_product
import application/queries/list_products
import application/shared/infrastructure_error
import common/product_id
import gleam/http
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import wisp
import wisp/simulate

pub const valid_product_id = "018f4e1a-0000-7000-8000-000000000001"

pub const missing_product_id = "018f4e1a-0000-7000-8000-000000000099"

pub fn request(method: http.Method, path: String) -> wisp.Request {
  simulate.request(method, path)
  |> simulate.header("Content-Type", "application/json")
  |> simulate.header("Accept", "application/json")
}

fn make_model(
  id: String,
  name: String,
  parent: Option(String),
  children: List(String),
) -> product_query_model.T {
  product_query_model.ProductQueryModel(
    id: id,
    name: name,
    parent_product_id: parent,
    children_ids: children,
  )
}

pub fn all_products() -> List(product_query_model.T) {
  [
    make_model("018f4e1a-0000-7000-8000-000000000001", "Espresso", None, []),
    make_model("018f4e1a-0000-7000-8000-000000000002", "Latte", None, [
      "018f4e1a-0000-7000-8000-000000000003",
      "018f4e1a-0000-7000-8000-000000000004",
    ]),
    make_model(
      "018f4e1a-0000-7000-8000-000000000003",
      "Cappuccino",
      Some("018f4e1a-0000-7000-8000-000000000002"),
      [],
    ),
    make_model(
      "018f4e1a-0000-7000-8000-000000000004",
      "Mocha Latte",
      Some("018f4e1a-0000-7000-8000-000000000002"),
      [],
    ),
  ]
}

pub fn list_products_port(
  paging_params: paging.Params,
) -> Result(list_products.Response, infrastructure_error.T) {
  let all = all_products()
  let items =
    all
    |> list.drop(page_offset.value(paging_params.offset))
    |> list.take(page_limit.value(paging_params.limit))

  Ok(paging.Response(data: items, total: list.length(all), paging_params:))
}

pub fn get_product_port(
  id: product_id.T,
) -> Result(product_query_model.T, get_product.GetProductError) {
  case
    list.find(all_products(), fn(product) { product.id == product_id.value(id) })
  {
    Ok(found) -> Ok(found)
    Error(_) -> Error(get_product.ProductNotFound)
  }
}

pub fn does_product_exist_port(
  id: product_id.T,
) -> Result(Bool, infrastructure_error.T) {
  let id_str = product_id.value(id)
  Ok(!string.ends_with(id_str, "99"))
}

pub fn create_product_port(
  _new_product: _,
) -> Result(Nil, infrastructure_error.T) {
  Ok(Nil)
}
