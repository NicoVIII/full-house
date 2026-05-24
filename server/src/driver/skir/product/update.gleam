import application/commands/products/update/command
import application/commands/products/update/ports
import application/shared/infrastructure_error
import driver/shared/parse_error
import driver/shared/products/update/request_parser
import driver/skirout/products/commands
import gleam/result
import skir_client/service.{type ServiceError, ServiceError}

fn map_command_error(error: command.Error) -> ServiceError {
  case error {
    command.ParentIdDoesntExist ->
      service.ServiceError(
        service.E400xBadRequest,
        "parent product id doesn't exist",
      )
    command.BarcodeToRemoveNotAssignedToProduct ->
      service.ServiceError(
        service.E400xBadRequest,
        "barcode to remove is not assigned to the product",
      )
    command.ProductNotFound ->
      service.ServiceError(service.E404xNotFound, "product not found")
    command.BarcodeAssignedToAnotherProduct ->
      service.ServiceError(
        service.E409xConflict,
        "barcode is already assigned to another product",
      )
    command.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: commands.UpdateProductRequest,
  ports: ports.T,
) -> Result(commands.UpdateProductResponse, ServiceError) {
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
    command.handle(command:, ports:)
    |> result.map_error(map_command_error),
  )

  Ok(commands.UpdateProductResponseSuccess)
}
