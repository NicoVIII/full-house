import application/page_limit
import application/page_offset
import application/ports/stock_repository
import domain/basics/uuid
import domain/product
import domain/stock_item
import gleam/list

type CatalogEntry {
  CatalogEntry(product_id: product.Id, product_name: String)
}

fn make_product_id(id_str: String) -> product.Id {
  product.ProductId(uuid.new_exn(id_str))
}

fn make_stock_item(id_str: String, product_id: product.Id) -> stock_item.T {
  stock_item.StockItem(id: uuid.new_exn(id_str), product_id: product_id)
}

fn stocked_catalog() -> List(CatalogEntry) {
  [
    CatalogEntry(
      product_id: make_product_id("018f4e1a-0000-7000-8000-000000000001"),
      product_name: "Espresso",
    ),
    CatalogEntry(
      product_id: make_product_id("018f4e1a-0000-7000-8000-000000000002"),
      product_name: "Cappuccino",
    ),
    CatalogEntry(
      product_id: make_product_id("018f4e1a-0000-7000-8000-000000000003"),
      product_name: "Latte",
    ),
    CatalogEntry(
      product_id: make_product_id("018f4e1a-0000-7000-8000-000000000007"),
      product_name: "Matcha",
    ),
    CatalogEntry(
      product_id: make_product_id("018f4e1a-0000-7000-8000-000000000009"),
      product_name: "Oat Latte",
    ),
  ]
}

fn mock_stock_items() -> List(stock_item.T) {
  let espresso_id = make_product_id("018f4e1a-0000-7000-8000-000000000001")
  let cappuccino_id = make_product_id("018f4e1a-0000-7000-8000-000000000002")
  let latte_id = make_product_id("018f4e1a-0000-7000-8000-000000000003")
  let matcha_id = make_product_id("018f4e1a-0000-7000-8000-000000000007")
  let oat_latte_id = make_product_id("018f4e1a-0000-7000-8000-000000000009")

  [
    make_stock_item("018f4e1a-1000-7000-8000-000000000001", espresso_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000002", espresso_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000003", espresso_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000004", espresso_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000005", cappuccino_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000006", cappuccino_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000007", latte_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000008", latte_id),
    make_stock_item("018f4e1a-1000-7000-8000-000000000009", latte_id),
    make_stock_item("018f4e1a-1000-7000-8000-00000000000a", matcha_id),
    make_stock_item("018f4e1a-1000-7000-8000-00000000000b", matcha_id),
    make_stock_item("018f4e1a-1000-7000-8000-00000000000c", matcha_id),
    make_stock_item("018f4e1a-1000-7000-8000-00000000000d", matcha_id),
    make_stock_item("018f4e1a-1000-7000-8000-00000000000e", matcha_id),
    make_stock_item("018f4e1a-1000-7000-8000-00000000000f", oat_latte_id),
  ]
}

fn quantity_for_product(
  items: List(stock_item.T),
  product_id: product.Id,
) -> Int {
  items
  |> list.filter(fn(item) { item.product_id == product_id })
  |> list.length
}

fn stock_summaries() -> List(stock_repository.StockSummary) {
  let items = mock_stock_items()

  stocked_catalog()
  |> list.map(fn(entry) {
    stock_repository.StockSummary(
      product_id: entry.product_id,
      product_name: entry.product_name,
      quantity: quantity_for_product(items, entry.product_id),
    )
  })
}

fn list_stock_mock(
  params: stock_repository.ListParams,
) -> Result(stock_repository.ListResult, Nil) {
  let stock_repository.ListParams(offset:, limit:) = params

  let all = stock_summaries()
  let total = list.length(all)

  let items =
    all
    |> list.drop(page_offset.value(offset))
    |> list.take(page_limit.value(limit))

  Ok(stock_repository.ListResult(items: items, total: total))
}

pub fn new() -> stock_repository.T {
  stock_repository.T(list: list_stock_mock)
}
