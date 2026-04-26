import domain/basics/uuid
import domain/product

/// Represents one physical inventory unit.
pub type T {
  StockItem(id: uuid.T, product_id: product.Id)
}
