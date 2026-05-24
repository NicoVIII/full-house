import application/queries/common/product_query_model
import application/queries/get_product_by_barcode
import application/shared/infrastructure_error
import domain/products/barcodes/barcode
import driver/skirout/products/queries
import gleam/result
import skir_client/service

fn map_product(model: product_query_model.T) -> queries.Product {
  queries.product_new(
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
  request: queries.GetProductByBarcodeRequest,
  port: get_product_by_barcode.GetProductByBarcodePort,
) -> Result(queries.Product, service.ServiceError) {
  use product_barcode <- result.try(
    barcode.from_user_input(request.barcode)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "barcode is invalid")
    }),
  )

  get_product_by_barcode.execute(product_barcode, port)
  |> result.map(map_product)
  |> result.map_error(map_error)
}
