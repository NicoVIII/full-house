import application/queries/ports/get as get_product_port
import domain/products/product

pub fn execute(
  repo: get_product_port.T,
  product_id: product.Id,
) -> Result(product.T, get_product_port.Error) {
  repo.get(product_id)
}
