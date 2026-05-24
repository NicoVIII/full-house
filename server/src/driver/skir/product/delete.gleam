import application/commands/products/delete/command
import application/commands/products/delete/ports
import application/shared/infrastructure_error
import driver/shared/products/delete/request_parser
import driver/skirout/products/commands
import gleam/result
import skir_client/service

fn map_error(error: command.Error) -> service.ServiceError {
  case error {
    command.ProductNotFound ->
      service.ServiceError(service.E404xNotFound, "product not found")
    command.DomainError(_) ->
      service.ServiceError(
        service.E409xConflict,
        "cannot delete product with active dependencies",
      )
    command.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: commands.DeleteProductRequest,
  ports: ports.T,
) -> Result(commands.DeleteProductResponse, service.ServiceError) {
  // Build command
  use command <- result.try(
    request_parser.parse(request)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "product id is invalid")
    }),
  )

  // Execute command and prepare response
  case command.handle(command, ports) {
    Ok(_) -> Ok(commands.DeleteProductResponseSuccess)
    Error(e) -> Error(map_error(e))
  }
}
