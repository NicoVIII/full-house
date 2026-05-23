import application/commands/create_product
import common/product_id
import composition
import domain/products/existing_product_id
import domain/products/product_name
import driver/skirout/product
import gleam/option
import gleam/result
import skir_client/service

pub fn handle(
  request: product.CreateProductRequest,
  context: composition.AppContext,
) -> Result(product.Product, service.ServiceError) {
  let command =
    create_product.Command(
      name: request.name,
      parent_product_id: request.parent_product_id,
    )

  use product <- result.try(
    create_product.execute(command, context.create_product_ports)
    |> result.map_error(fn(e) {
      case e {
        create_product.InvalidName ->
          service.ServiceError(service.E400xBadRequest, "invalid name")
        create_product.InvalidParentId ->
          service.ServiceError(
            service.E400xBadRequest,
            "invalid parent_product_id",
          )
        create_product.ParentDoesNotExist ->
          service.ServiceError(
            service.E400xBadRequest,
            "parent product does not exist",
          )
        create_product.InfrastructureError(_) ->
          service.ServiceError(
            service.E500xInternalServerError,
            "infrastructure error",
          )
      }
    }),
  )

  product.product_new(
    [],
    product_id.value(product.id),
    product_name.value(product.name),
    option.map(product.parent_product_id, existing_product_id.value),
  )
  |> Ok
}
