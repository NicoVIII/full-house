import application/commands/delete_product
import application/shared/infrastructure_error
import common/product_id
import domain/basics/non_empty_set
import domain/products/deletable_product_id
import driver/http/handler_helpers
import gleam/json
import gleam/list
import wisp

fn error_response(error: delete_product.Error) -> wisp.Response {
  case error {
    delete_product.ProductNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("product not found")),
          ]),
        ),
        404,
      )
    delete_product.DomainError(domain_errors) ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("conflict")),
            #(
              "messages",
              json.array(
                domain_errors
                  |> non_empty_set.to_list
                  |> list.map(fn(error) {
                    case error {
                      deletable_product_id.HasChildren ->
                        "cannot delete product with child products"
                      deletable_product_id.HasStockItems ->
                        "cannot delete product with existing stock items"
                    }
                  }),
                of: json.string,
              ),
            ),
          ]),
        ),
        409,
      )
    delete_product.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  id_raw id_raw: String,
  ports ports: delete_product.Ports,
) -> wisp.Response {
  use product_id <-
    product_id.new(id_raw)
    |> handler_helpers.on_error_value(handler_helpers.bad_request(
      "product id is invalid",
    ))
  let command = delete_product.Command(id: product_id)

  case delete_product.execute(command, ports) {
    Ok(Nil) -> wisp.response(204)
    Error(error) -> error_response(error)
  }
}
