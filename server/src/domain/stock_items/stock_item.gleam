import common/product_id
import common/uuid

/// Represents one physical inventory unit.
pub type T {
  StockItem(id: uuid.T, product_id: product_id.T)
}
