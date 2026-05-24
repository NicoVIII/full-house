import application/commands/products/create/command
import common/product_id
import domain/products/barcodes/barcode
import domain/products/product_name
import driver/shared/parse_error.{ParseError}
import driver/skirout/products/commands
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set

type Error {
  InvalidId
  InvalidName
  InvalidParentProductId
  InvalidBarcodes
}

fn parse_internal(
  request: commands.CreateProductRequest,
) -> Result(command.T, Error) {
  use id <- result.try(
    product_id.new(request.id) |> result.map_error(fn(_) { InvalidId }),
  )
  use name <- result.try(
    product_name.new(request.name) |> result.map_error(fn(_) { InvalidName }),
  )
  use parent_product_id <- result.try(
    case request.parent_product_id {
      Some(raw_id) -> product_id.new(raw_id) |> result.map(Some)
      None -> Ok(None)
    }
    |> result.map_error(fn(_) { InvalidParentProductId }),
  )
  use barcodes <- result.try(
    request.barcodes
    |> list.try_map(barcode.new)
    |> result.map(set.from_list)
    |> result.map_error(fn(_) { InvalidBarcodes }),
  )

  Ok(command.Command(id:, name:, parent_product_id:, barcodes:))
}

pub fn parse(
  request: commands.CreateProductRequest,
) -> Result(command.T, parse_error.T) {
  parse_internal(request)
  |> result.map_error(fn(e) {
    case e {
      InvalidId -> ParseError("id is invalid")
      InvalidName -> ParseError("name is invalid")
      InvalidParentProductId -> ParseError("parent_product_id is invalid")
      InvalidBarcodes -> ParseError("barcodes are invalid")
    }
  })
}
