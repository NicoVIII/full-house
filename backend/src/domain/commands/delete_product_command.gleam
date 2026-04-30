import domain/products/product

pub type T {
  DeleteProductCommand(product_id: product.Id)
}
