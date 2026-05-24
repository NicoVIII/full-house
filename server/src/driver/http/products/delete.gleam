import application/commands/products/delete/command
import application/commands/products/delete/ports
import application/shared/infrastructure_error
import domain/basics/non_empty_list
import domain/basics/non_empty_set
import domain/products/product
import driver/http/handler_helpers
import driver/shared/parse_error
import driver/shared/products/delete/request_parser
import driver/skirout/products/commands
import wisp

fn error_response(error: command.Error) -> wisp.Response {
  case error {
    command.ProductNotFound -> wisp.not_found()
    command.DomainError(domain_errors) -> {
      let domain_error =
        domain_errors
        |> non_empty_set.to_non_empty_list()
        |> non_empty_list.first()
      case domain_error {
        product.HasChildren -> "cannot delete product with child products"
        product.HasStockItems ->
          "cannot delete product with existing stock items"
      }
      |> handler_helpers.conflict
    }
    command.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(id id: String, ports ports: ports.T) -> wisp.Response {
  // Build command
  use command <-
    commands.delete_product_request_new(id)
    |> request_parser.parse()
    |> handler_helpers.on_error(fn(e) {
      case e {
        parse_error.ParseError(message) -> wisp.bad_request(message)
      }
    })

  // Execute command and prepare response
  use Nil <-
    command.handle(command, ports)
    |> handler_helpers.on_error(error_response)

  wisp.no_content()
}
