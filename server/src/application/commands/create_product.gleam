import application/shared/infrastructure_error
import common/product_id
import domain/products/barcode
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type ProductExistencePort =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

pub type CreatePort =
  fn(product.T) -> Result(Nil, infrastructure_error.T)

pub type Ports {
  Ports(does_product_exist: ProductExistencePort, create: CreatePort)
}

pub type Command {
  Command(
    name: String,
    parent_product_id: Option(String),
    barcodes: List(String),
  )
}

pub type Error {
  InvalidName
  InvalidParentId
  InvalidBarcode
  ParentDoesNotExist
  InfrastructureError(infrastructure_error.T)
}

fn parse_barcodes(
  raw_barcodes: List(String),
) -> Result(List(barcode.T), Error) {
  raw_barcodes
  |> list.try_map(fn(raw) {
    barcode.from_user_input(raw)
    |> result.map_error(fn(_) { InvalidBarcode })
  })
}

pub fn execute(
  command command: Command,
  ports ports: Ports,
) -> Result(product.T, Error) {
  let Command(name, parent_product_id_opt, raw_barcodes) = command

  // Validate inputs
  use name <- result.try(
    product_name.new(name)
    |> result.map_error(fn(_) { InvalidName }),
  )

  // Prepare parent product id if provided
  use parent_product_id <- result.try(case parent_product_id_opt {
    None -> Ok(None)
    Some(parent_id) -> {
      use parent_id <- result.try(
        product_id.new(parent_id)
        |> result.map_error(fn(_) { InvalidParentId }),
      )

      use parent_exists <- result.try(
        ports.does_product_exist(parent_id)
        |> result.map_error(InfrastructureError),
      )

      case existing_product_id.prove(parent_id, parent_exists) {
        Ok(existing_id) -> Ok(Some(existing_id))
        Error(existing_product_id.ProductNotFound) -> Error(ParentDoesNotExist)
      }
    }
  })

  use parsed_barcodes <- result.try(parse_barcodes(raw_barcodes))

  let new_product =
    product.T(
      id: product_id.generate(),
      name: name,
      parent_product_id: parent_product_id,
      barcodes: parsed_barcodes,
    )

  use Nil <- result.try(
    ports.create(new_product)
    |> result.map_error(InfrastructureError),
  )

  Ok(new_product)
}
