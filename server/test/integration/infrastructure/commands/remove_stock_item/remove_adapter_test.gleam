import application/commands/remove_stock_item
import common/product_id
import common/uuid
import domain/stock_items/best_before_date
import domain/stock_items/stock_item
import infrastructure/adapter/commands/create_stock_item/create_adapter
import infrastructure/adapter/commands/remove_stock_item/remove_adapter
import integration/infrastructure/testdatabase

pub fn remove_stock_item_removes_one_and_returns_remaining_quantity_test() {
  let connection = testdatabase.setup()
  let create_port = create_adapter.new(connection)
  let remove_port = remove_adapter.new(connection)

  let assert Ok(item_product_id) =
    product_id.new("018f4e1a-0000-7000-8000-000000000001")
  let assert Ok(item_best_before_date) = best_before_date.new("2026-12-31")

  // Seed one extra item for the same product/date bucket so removing one leaves one.
  let assert Ok(seed_item) =
    remove_stock_item_test_item(
      "018f4e1a-0000-7000-8000-0000000000f9",
      item_product_id,
      item_best_before_date,
    )
  let assert Ok(Nil) = create_port(seed_item)

  let assert Ok(outcome) = remove_port(item_product_id, item_best_before_date)
  assert outcome == remove_stock_item.Removed(1)
}

pub fn remove_stock_item_returns_not_found_when_no_item_matches_test() {
  let connection = testdatabase.setup()
  let remove_port = remove_adapter.new(connection)

  let assert Ok(item_product_id) =
    product_id.new("018f4e1a-0000-7000-8000-000000000001")
  let assert Ok(item_best_before_date) = best_before_date.new("2030-01-01")

  let assert Ok(outcome) = remove_port(item_product_id, item_best_before_date)

  assert outcome == remove_stock_item.NotFound
}

fn remove_stock_item_test_item(
  id: String,
  item_product_id: product_id.T,
  item_best_before_date: best_before_date.T,
) {
  let assert Ok(item_id) = uuid.new(id)

  Ok(stock_item.StockItem(
    id: item_id,
    product_id: item_product_id,
    best_before_date: item_best_before_date,
  ))
}
