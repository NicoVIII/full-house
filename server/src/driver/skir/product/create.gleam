import application/commands/products/create/command
import application/commands/products/create/ports
import driver/shared/parse_error
import driver/shared/products/create/request_parser
import driver/skirout/products/commands
import gleam/result
import skir_client/service.{ServiceError}

pub fn handle(
  request: commands.CreateProductRequest,
  ports: ports.T,
) -> Result(commands.CreateProductResponse, service.ServiceError) {
  // Build command
  use command <- result.try(
    request_parser.parse(request)
    |> result.map_error(fn(e) {
      case e {
        parse_error.ParseError(message) ->
          ServiceError(service.E400xBadRequest, message)
      }
    }),
  )

  // Execute command
  use Nil <- result.try(
    command.handle(command, ports)
    |> result.map_error(fn(e) {
      case e {
        command.IdAlreadyExists ->
          ServiceError(
            service.E409xConflict,
            "product with the same id already exists",
          )
        command.ParentDoesNotExist ->
          ServiceError(service.E400xBadRequest, "parent product does not exist")
        command.BarcodeAssignedToAnotherProduct ->
          ServiceError(
            service.E409xConflict,
            "barcode is already assigned to another product",
          )
        command.InfrastructureError(_) ->
          ServiceError(service.E500xInternalServerError, "infrastructure error")
      }
    }),
  )

  Ok(commands.CreateProductResponseSuccess)
}
