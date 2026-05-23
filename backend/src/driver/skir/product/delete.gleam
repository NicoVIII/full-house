import application/commands/delete_product
import application/shared/infrastructure_error
import common/product_id
import composition
import driver/skirout/product
import gleam/result
import skir_client/service

fn map_error(error: delete_product.Error) -> service.ServiceError {
  case error {
    delete_product.ProductNotFound ->
      service.ServiceError(service.E404xNotFound, "product not found")
    delete_product.DomainError(_) ->
      service.ServiceError(
        service.E409xConflict,
        "cannot delete product with active dependencies",
      )
    delete_product.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: product.DeleteProductRequest,
  context: composition.AppContext,
) -> Result(product.DeleteProductResponse, service.ServiceError) {
  use id <- result.try(
    product_id.new(request.id)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "product id is invalid")
    }),
  )

  delete_product.execute(
    delete_product.Command(id: id),
    context.delete_product_ports,
  )
  |> result.map(fn(_) { product.delete_product_response_new() })
  |> result.map_error(map_error)
}
