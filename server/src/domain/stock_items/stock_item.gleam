import common/product_id
import common/uuid_v7
import domain/stock_items/best_before_date

/// Represents one physical inventory unit.
pub type T {
  StockItem(
    id: uuid_v7.T,
    product_id: product_id.T,
    best_before_date: best_before_date.T,
  )
}
