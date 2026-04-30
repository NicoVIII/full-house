import domain/products/product

pub type T {
  Command(product_id: product.Id)
}
