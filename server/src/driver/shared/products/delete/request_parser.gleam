import application/commands/products/delete/command
import common/product_id
import driver/shared/parse_error.{ParseError}
import driver/skirout/products/commands
import gleam/result

type Error {
  InvalidId
}

fn parse_internal(
  request: commands.DeleteProductRequest,
) -> Result(command.T, Error) {
  use id <- result.try(
    product_id.new(request.id)
    |> result.map_error(fn(_) { InvalidId }),
  )
  Ok(command.Command(id:))
}

pub fn parse(
  request: commands.DeleteProductRequest,
) -> Result(command.T, parse_error.T) {
  parse_internal(request)
  |> result.map_error(fn(e) {
    case e {
      InvalidId -> ParseError("id is invalid")
    }
  })
}
