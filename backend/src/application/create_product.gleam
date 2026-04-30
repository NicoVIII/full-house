import application/ports/products/create as create_product_port
import domain/basics/uuid
import domain/commands/create_product_command
import domain/product
import gleam/result

pub type CreateProductResult {
  CreateProductResult(product: product.T)
}

pub fn execute(
  repo: create_product_port.T,
  command: create_product_command.T,
) -> Result(CreateProductResult, create_product_port.Error) {
  let create_product_command.CreateProductCommand(name, parent_product_id) =
    command

  let new_product =
    product.Product(
      id: product.ProductId(uuid.generate_v7()),
      name: name,
      parent_product_id: parent_product_id,
    )

  use Nil <- result.try(repo.create(new_product))

  Ok(CreateProductResult(product: new_product))
}
