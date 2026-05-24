import application/commands/command_result
import application/commands/products/update/ports
import application/shared/infrastructure_error
import common/product_id
import domain/basics/non_empty_list
import domain/basics/non_empty_set
import domain/products/barcodes/barcode
import domain/products/barcodes/unassigned_barcode
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/option.{None, Some}
import gleam/result

pub type Change {
  ChangeName(name: product_name.T)
  ChangeParentId(parent_product_id: option.Option(product_id.T))
  AddBarcodes(barcodes: non_empty_set.T(barcode.T))
  RemoveBarcodes(barcodes: non_empty_set.T(barcode.T))
}

pub type T {
  Command(id: product_id.T, changes: non_empty_list.T(Change))
}

pub type Error {
  ProductNotFound
  ParentIdDoesntExist
  BarcodeAssignedToAnotherProduct
  BarcodeToRemoveNotAssignedToProduct
  InfrastructureError(infrastructure_error.T)
}

fn apply_change(
  product: product.T,
  change: Change,
  ports: ports.T,
) -> Result(product.T, Error) {
  case change {
    ChangeName(name) -> product.change_name(product, name) |> Ok
    ChangeParentId(parent_product_id) -> {
      use parent_product_id <- result.try(case parent_product_id {
        Some(id) -> {
          use exists <- result.try(
            ports.does_product_exist(id)
            |> result.map_error(InfrastructureError),
          )
          case existing_product_id.prove(id, exists:) {
            Ok(existing_id) -> Ok(Some(existing_id))
            Error(_) -> Error(ParentIdDoesntExist)
          }
        }
        None -> None |> Ok
      })
      product.change_parent_product_id(product, parent_product_id) |> Ok
    }
    AddBarcodes(barcodes) -> {
      use unassigned_barcodes <- result.try(
        non_empty_set.try_map(barcodes, fn(barcode) {
          use is_assigned <- result.try(
            ports.is_barcode_assigned(barcode)
            |> result.map_error(InfrastructureError),
          )
          unassigned_barcode.prove(barcode, is_assigned)
          |> result.map_error(fn(e) {
            case e {
              unassigned_barcode.AlreadyAssigned ->
                BarcodeAssignedToAnotherProduct
            }
          })
        }),
      )
      product.add_barcodes(product, unassigned_barcodes) |> Ok
    }
    RemoveBarcodes(barcodes) ->
      product.remove_barcodes(product, barcodes)
      |> result.map_error(fn(e) {
        case e {
          product.BarcodeNotAssignedToProduct ->
            BarcodeToRemoveNotAssignedToProduct
        }
      })
  }
}

pub fn handle(
  command command: T,
  ports ports: ports.T,
) -> command_result.T(Error) {
  // Load
  use product <- result.try(
    ports.load_product(command.id)
    |> result.map_error(fn(e) {
      case e {
        ports.LoadProductNotFound -> ProductNotFound
        ports.LoadProductInfrastructureError(infra_error) ->
          InfrastructureError(infra_error)
      }
    }),
  )

  // Apply changes
  use updated_product <- result.try(
    non_empty_list.fold(command.changes, Ok(product), fn(result, change) {
      use product <- result.try(result)
      apply_change(product, change, ports)
    }),
  )

  // Persist
  ports.update(updated_product)
  |> result.map_error(fn(e) { InfrastructureError(e) })
}
