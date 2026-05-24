import application/commands/stock_items/create/command
import application/commands/stock_items/create/ports
import application/shared/infrastructure_error
import driver/shared/parse_error
import driver/shared/stock_items/create/request_parser
import driver/skirout/stock_items/commands
import gleam/result
import skir_client/service.{ServiceError}

fn map_error(error: command.Error) -> service.ServiceError {
  case error {
    command.ProductDoesNotExist ->
      service.ServiceError(
        service.E400xBadRequest,
        "product_id does not reference an existing product",
      )
    command.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: commands.CreateStockItemRequest,
  ports: ports.T,
) -> Result(commands.CreateStockItemResponse, service.ServiceError) {
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
    |> result.map_error(map_error),
  )

  Ok(commands.CreateStockItemResponseSuccess)
}
