import application/shared/infrastructure_error
import common/product_id
import domain/products/barcode
import gleam/list
import gleam/result

pub type UpdateBarcodesPortError {
  PortProductNotFound
  PortBarcodeAssignedToAnotherProduct(conflicting_product_name: String)
  PortInfrastructureError(infrastructure_error.T)
}

pub type UpdateBarcodesPort =
  fn(product_id.T, List(barcode.T), List(barcode.T)) ->
    Result(Nil, UpdateBarcodesPortError)

pub type Command {
  Command(
    id: product_id.T,
    add_barcodes: List(String),
    remove_barcodes: List(String),
  )
}

pub type Error {
  InvalidBarcode
  ProductNotFound
  BarcodeAssignedToAnotherProduct(conflicting_product_name: String)
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
  port update_barcodes: UpdateBarcodesPort,
) -> Result(Nil, Error) {
  let Command(id:, add_barcodes:, remove_barcodes:) = command

  use parsed_additions <- result.try(parse_barcodes(add_barcodes))
  use parsed_removals <- result.try(parse_barcodes(remove_barcodes))

  update_barcodes(id, parsed_additions, parsed_removals)
  |> result.map_error(fn(error) {
    case error {
      PortProductNotFound -> ProductNotFound
      PortBarcodeAssignedToAnotherProduct(name) ->
        BarcodeAssignedToAnotherProduct(name)
      PortInfrastructureError(reason) -> InfrastructureError(reason)
    }
  })
}
