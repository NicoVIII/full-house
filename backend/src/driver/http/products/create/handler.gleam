import application/commands/create_product
import application/commands/ports/create as create_product_port
import application/commands/ports/validate_parent_product as validate_parent_product_port
import domain/products/creation/command as create_product_command
import driver/http/handler_helpers
import driver/http/products/create/request_mapper
import driver/http/products/create/response_mapper
import gleam/http
import wisp

fn create_error_response(error: create_product.Error) -> wisp.Response {
  case error {
    create_product.ValidationFailed(validation_error) ->
      case validation_error {
        validate_parent_product_port.ParentProductNotFound ->
          handler_helpers.bad_request(
            "parent_product_id does not reference an existing product",
          )
        validate_parent_product_port.DatabaseFailure ->
          wisp.internal_server_error()
      }
    create_product.CreationFailed(creation_error) ->
      case creation_error {
        create_product_port.ParentProductNotFound ->
          handler_helpers.bad_request(
            "parent_product_id does not reference an existing product",
          )
        _ -> wisp.internal_server_error()
      }
  }
}

pub fn handle(
  request: wisp.Request,
  validate_parent_repo: validate_parent_product_port.T,
  create_repo: create_product_port.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use payload <- wisp.require_json(request)

  case request_mapper.map_payload(payload) {
    Error(message) -> handler_helpers.bad_request(message)
    Ok(#(name, parent_product_id)) -> {
      let command =
        create_product_command.Command(
          name: name,
          parent_product_id: parent_product_id,
        )

      case create_product.execute(validate_parent_repo, create_repo, command) {
        Ok(result) -> {
          let body = response_mapper.map_create_product_response(result)
          wisp.json_response(body, 201)
        }
        Error(error) -> create_error_response(error)
      }
    }
  }
}
