import application/queries/common/product_query_model
import application/queries/get_product
import application/shared/infrastructure_error
import common/product_id
import composition
import driver/skirout/product
import gleam/result
import skir_client/service

fn map_product(model: product_query_model.T) -> product.Product {
  product.product_new(
    model.children_ids,
    model.id,
    model.name,
    model.parent_product_id,
  )
}

fn map_error(error: get_product.GetProductError) -> service.ServiceError {
  case error {
    get_product.ProductNotFound ->
      service.ServiceError(service.E404xNotFound, "product not found")
    get_product.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: product.GetProductRequest,
  context: composition.AppContext,
) -> Result(product.Product, service.ServiceError) {
  use id <- result.try(
    product_id.new(request.id)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "product id is invalid")
    }),
  )

  get_product.execute(id, context.get_product_port)
  |> result.map(map_product)
  |> result.map_error(map_error)
}
