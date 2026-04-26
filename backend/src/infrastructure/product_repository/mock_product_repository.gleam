import application/page_limit
import application/page_offset
import application/ports/product_repository
import domain/basics/uuid
import domain/product
import gleam/list
import gleam/option.{None, Some}

fn make_product(id_str: String, name: String) -> product.T {
  let uid = uuid.new_exn(id_str)
  product.Product(
    id: product.ProductId(uid),
    name: name,
    parent_product_id: None,
  )
}

fn make_child_product(
  id_str: String,
  name: String,
  parent_id: product.Id,
) -> product.T {
  let uid = uuid.new_exn(id_str)
  product.Product(
    id: product.ProductId(uid),
    name: name,
    parent_product_id: Some(parent_id),
  )
}

fn mock_products() -> List(product.T) {
  let espresso =
    make_product("018f4e1a-0000-7000-8000-000000000001", "Espresso")
  let cappuccino =
    make_product("018f4e1a-0000-7000-8000-000000000002", "Cappuccino")
  let latte = make_product("018f4e1a-0000-7000-8000-000000000003", "Latte")
  let americano =
    make_product("018f4e1a-0000-7000-8000-000000000004", "Americano")
  let flat_white =
    make_product("018f4e1a-0000-7000-8000-000000000005", "Flat White")
  let cold_brew =
    make_product("018f4e1a-0000-7000-8000-000000000006", "Cold Brew")
  let matcha = make_product("018f4e1a-0000-7000-8000-000000000007", "Matcha")
  let chai = make_product("018f4e1a-0000-7000-8000-000000000008", "Chai")
  let oat_latte =
    make_child_product(
      "018f4e1a-0000-7000-8000-000000000009",
      "Oat Latte",
      latte.id,
    )
  let soy_latte =
    make_child_product(
      "018f4e1a-0000-7000-8000-00000000000a",
      "Soy Latte",
      latte.id,
    )

  [
    espresso, cappuccino, latte, americano, flat_white, cold_brew, matcha, chai,
    oat_latte, soy_latte,
  ]
}

fn list_products_mock(
  params: product_repository.ListParams,
) -> Result(product_repository.ListResult, Nil) {
  let product_repository.ListParams(offset:, limit:) = params

  let all = mock_products()
  let total = list.length(all)

  let items =
    all
    |> list.drop(page_offset.value(offset))
    |> list.take(page_limit.value(limit))

  Ok(product_repository.ListResult(items: items, total: total))
}

pub fn new() -> product_repository.T {
  product_repository.T(list: list_products_mock)
}
