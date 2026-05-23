import common/product_id
import common/uuid
import domain/stock_items/best_before_date

/// Represents one physical inventory unit.
pub type T {
  StockItem(
    id: uuid.T,
    product_id: product_id.T,
    best_before_date: best_before_date.T,
  )
}
