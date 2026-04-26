import application/ports/products/create as create_product_port
import domain/basics/uuid
import domain/product
import domain/product_name
import gleam/option.{type Option}
import gleam/result

pub type CreateProductResult {
  CreateProductResult(product: product.T)
}

pub fn execute(
  repo: create_product_port.T,
  name: product_name.T,
  parent_product_id: Option(product.Id),
) -> Result(CreateProductResult, create_product_port.Error) {
  let new_product =
    product.Product(
      id: product.ProductId(uuid.generate_v7()),
      name: name,
      parent_product_id: parent_product_id,
    )

  use Nil <- result.try(repo.create(new_product))

  Ok(CreateProductResult(product: new_product))
}
