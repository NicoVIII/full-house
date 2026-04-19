import domain/basics/uuid
import domain/product

/// This represents a physical item you have in stock
pub type T {
  StockItem(id: uuid.T, product_id: product.Id)
}
