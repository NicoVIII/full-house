import application/commands/products/update/command
import common/product_id
import domain/basics/non_empty_list
import domain/basics/non_empty_set
import domain/products/barcodes/barcode
import driver/shared/parse_error.{ParseError}
import driver/skirout/products/commands
import gleam/list
import gleam/option.{None, Some}
import gleam/result

type Error {
  InvalidId
  InvalidBarcode
  NoChangesProvided
}

fn parse_internal(
  request: commands.UpdateProductRequest,
) -> Result(command.T, Error) {
  use id <- result.try(
    product_id.new(request.id)
    |> result.map_error(fn(_) { InvalidId }),
  )

  use add_barcodes_change <- result.try(
    case non_empty_set.from_list(request.add_barcodes) {
      Ok(add_barcodes) ->
        add_barcodes
        |> non_empty_set.try_map(barcode.new)
        |> result.map(fn(barcodes) { command.AddBarcodes(barcodes) |> Some })
      Error(_) -> Ok(None)
    }
    |> result.map_error(fn(_) { InvalidBarcode }),
  )

  use remove_barcodes_change <- result.try(
    case non_empty_set.from_list(request.remove_barcodes) {
      Ok(remove_barcodes) ->
        remove_barcodes
        |> non_empty_set.try_map(barcode.new)
        |> result.map(fn(barcodes) { command.RemoveBarcodes(barcodes) |> Some })
      Error(_) -> Ok(None)
    }
    |> result.map_error(fn(_) { InvalidBarcode }),
  )

  use changes <- result.try(
    [add_barcodes_change, remove_barcodes_change]
    |> list.filter_map(option.to_result(_, Nil))
    |> non_empty_list.from_list
    |> result.map_error(fn(_) { NoChangesProvided }),
  )

  Ok(command.Command(id:, changes:))
}

pub fn parse(
  request: commands.UpdateProductRequest,
) -> Result(command.T, parse_error.T) {
  parse_internal(request)
  |> result.map_error(fn(e) {
    case e {
      InvalidId -> ParseError("id is invalid")
      InvalidBarcode -> ParseError("one or more barcodes are invalid")
      NoChangesProvided -> ParseError("no changes provided")
    }
  })
}
