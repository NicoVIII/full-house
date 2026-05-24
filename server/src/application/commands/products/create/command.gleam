import application/commands/command_result
import application/commands/products/create/ports
import application/shared/infrastructure_error
import common/product_id
import domain/products/barcodes/barcode
import domain/products/barcodes/unassigned_barcode
import domain/products/existing_product_id
import domain/products/non_existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}

pub type T {
  Command(
    id: product_id.T,
    name: product_name.T,
    parent_product_id: Option(product_id.T),
    barcodes: Set(barcode.T),
  )
}

pub type Error {
  IdAlreadyExists
  ParentDoesNotExist
  BarcodeAssignedToAnotherProduct(conflicting_product_name: String)
  InfrastructureError(infrastructure_error.T)
}

fn check_existence(
  id: product_id.T,
  does_product_exist: ports.ProductExistence,
) -> Result(Bool, Error) {
  does_product_exist(id)
  |> result.map_error(fn(e) { InfrastructureError(e) })
}

fn check_id(
  id: product_id.T,
  does_product_exist: ports.ProductExistence,
) -> Result(non_existing_product_id.T, Error) {
  use does_id_exist <- result.try(check_existence(id, does_product_exist))

  non_existing_product_id.prove(id, exists: does_id_exist)
  |> result.map_error(fn(e) {
    case e {
      non_existing_product_id.ProductAlreadyExists -> IdAlreadyExists
    }
  })
}

fn check_parent_id(
  parent_product_id_opt: Option(product_id.T),
  does_product_exist: ports.ProductExistence,
) -> Result(Option(existing_product_id.T), Error) {
  case parent_product_id_opt {
    None -> Ok(None)
    Some(parent_id) -> {
      use parent_exists <- result.try(check_existence(
        parent_id,
        does_product_exist,
      ))

      existing_product_id.prove(parent_id, exists: parent_exists)
      |> result.map_error(fn(e) {
        case e {
          existing_product_id.ProductNotFound -> ParentDoesNotExist
        }
      })
      |> result.map(Some)
    }
  }
}

fn check_barcodes(
  barcodes: Set(barcode.T),
  is_barcode_assigned: ports.BarcodeAssignment,
) -> Result(Set(unassigned_barcode.T), Error) {
  barcodes
  |> set.to_list
  |> list.try_map(fn(product_barcode) {
    is_barcode_assigned(product_barcode)
    |> fn(result) {
      case result {
        Ok(is_assigned) ->
          unassigned_barcode.prove(product_barcode, assigned: is_assigned)
          |> result.map_error(fn(e) {
            case e {
              unassigned_barcode.AlreadyAssigned ->
                BarcodeAssignedToAnotherProduct("Conflicting Product")
            }
          })
        Error(e) -> Error(InfrastructureError(e))
      }
    }
  })
  |> result.map(set.from_list)
}

pub fn handle(
  command command: T,
  ports ports: ports.T,
) -> command_result.T(Error) {
  // Check inputs
  use new_id <- result.try(check_id(command.id, ports.does_product_exist))
  use parent_product_id <- result.try(check_parent_id(
    command.parent_product_id,
    ports.does_product_exist,
  ))
  use barcodes <- result.try(check_barcodes(
    command.barcodes,
    ports.is_barcode_assigned,
  ))

  // Create new product
  let new_product =
    product.create(new_id, command.name, parent_product_id, barcodes)

  // Persist
  ports.create(new_product)
  |> result.map_error(fn(e) {
    case e {
      ports.BarcodeAlreadyAssigned(conflicting_name) ->
        BarcodeAssignedToAnotherProduct(conflicting_name)
      ports.InfrastructureError(reason) -> InfrastructureError(reason)
    }
  })
}
