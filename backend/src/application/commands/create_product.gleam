import application/commands/ports/create as create_product_port
import application/commands/ports/validate_parent_product as validate_parent_product_port
import domain/basics/uuid
import domain/products/creation/command as create_product_command
import domain/products/creation/policy as create_product_policy
import domain/products/creation/validated_parent_id as validated_parent_product_id
import domain/products/product
import gleam/option
import gleam/result

pub type CreateProductResult {
  CreateProductResult(product: product.T)
}

pub type Error {
  ValidationFailed(validate_parent_product_port.Error)
  CreationFailed(create_product_port.Error)
}

pub fn execute(
  validate_parent_repo: validate_parent_product_port.T,
  create_repo: create_product_port.T,
  command: create_product_command.T,
) -> Result(CreateProductResult, Error) {
  let create_product_command.Command(name, parent_product_id) = command

  // Step 1: Validate parent product exists (if provided)
  use validated_parent_opt <- result.try(
    validate_parent_repo.validate(parent_product_id)
    |> result.map_error(ValidationFailed),
  )

  // Step 2: Apply creation policy (if parent is provided)
  use Nil <- result.try(case validated_parent_opt {
    option.None -> Ok(Nil)
    option.Some(validated_parent) ->
      create_product_policy.can_create(validated_parent)
      |> result.map_error(fn(_) {
        CreationFailed(create_product_port.DatabaseFailure)
      })
  })

  // Step 3: Create the product
  let new_product =
    product.Product(
      id: product.ProductId(uuid.generate_v7()),
      name: name,
      parent_product_id: case validated_parent_opt {
        option.None -> option.None
        option.Some(validated_parent) ->
          option.Some(validated_parent_product_id.value(validated_parent))
      },
    )

  use Nil <- result.try(
    create_repo.create(new_product)
    |> result.map_error(CreationFailed),
  )

  Ok(CreateProductResult(product: new_product))
}
