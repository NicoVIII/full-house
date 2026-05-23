import common/product_id
import common/uuid
import domain/stock_items/best_before_date
import domain/stock_items/stock_item
import gleam/dynamic/decode
import infrastructure/adapter/commands/create_stock_item/create_adapter
import integration/infrastructure/testdatabase
import sqlight

fn best_before_date_decoder() -> decode.Decoder(String) {
  decode.field(0, decode.string, decode.success)
}

pub fn create_stock_item_persists_best_before_date_test() {
  let connection = testdatabase.setup()
  let create_port = create_adapter.new(connection)

  let assert Ok(item_id) = uuid.new("018f4e1a-0000-7000-8000-0000000000f2")
  let assert Ok(item_product_id) =
    product_id.new("018f4e1a-0000-7000-8000-000000000001")
  let assert Ok(item_best_before_date) = best_before_date.new("2026-11-15")

  let item =
    stock_item.StockItem(
      id: item_id,
      product_id: item_product_id,
      best_before_date: item_best_before_date,
    )

  let assert Ok(Nil) = create_port(item)

  let assert Ok(stored_best_before_dates) =
    sqlight.query(
      "
      SELECT best_before_date
      FROM stock_items
      WHERE id = ?
      ",
      on: connection,
      with: [sqlight.text(uuid.value(item_id))],
      expecting: best_before_date_decoder(),
    )

  assert stored_best_before_dates == ["2026-11-15"]
}
