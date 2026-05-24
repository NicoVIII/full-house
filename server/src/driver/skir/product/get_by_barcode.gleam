import application/queries/common/product_query_model
import application/queries/get_product_by_barcode
import application/shared/infrastructure_error
import composition
import domain/products/barcode
import driver/skirout/product
import gleam/result
import skir_client/service

fn map_product(model: product_query_model.T) -> product.Product {
  product.product_new(
    model.barcodes,
    model.children_ids,
    model.id,
    model.name,
    model.parent_product_id,
  )
}

fn map_error(
  error: get_product_by_barcode.GetProductByBarcodeError,
) -> service.ServiceError {
  case error {
    get_product_by_barcode.ProductNotFound ->
      service.ServiceError(service.E404xNotFound, "product not found")
    get_product_by_barcode.InfrastructureError(
      infrastructure_error.DatabaseFailure,
    ) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: product.GetProductByBarcodeRequest,
  context: composition.AppContext,
) -> Result(product.Product, service.ServiceError) {
  use product_barcode <- result.try(
    barcode.from_user_input(request.barcode)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "barcode is invalid")
    }),
  )

  get_product_by_barcode.execute(
    product_barcode,
    context.get_product_by_barcode_port,
  )
  |> result.map(map_product)
  |> result.map_error(map_error)
}
