import application/commands/remove_stock_item
import application/shared/infrastructure_error
import common/product_id
import composition
import domain/stock_items/best_before_date
import driver/skirout/stock
import gleam/result
import skir_client/service

fn map_error(error: remove_stock_item.Error) -> service.ServiceError {
  case error {
    remove_stock_item.StockItemNotFound ->
      service.ServiceError(service.E404xNotFound, "stock item not found")
    remove_stock_item.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

fn map_response(
  response: remove_stock_item.Response,
) -> stock.RemoveStockItemResponse {
  let remove_stock_item.Response(
    product_id: item_product_id,
    best_before_date: item_best_before_date,
    remaining_quantity:,
  ) = response

  stock.remove_stock_item_response_new(
    best_before_date.value(item_best_before_date),
    product_id.value(item_product_id),
    remaining_quantity,
  )
}

pub fn handle(
  request: stock.RemoveStockItemRequest,
  context: composition.AppContext,
) -> Result(stock.RemoveStockItemResponse, service.ServiceError) {
  use id <- result.try(
    product_id.new(request.product_id)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "product id is invalid")
    }),
  )

  use item_best_before_date <- result.try(
    best_before_date.new(request.best_before_date)
    |> result.map_error(fn(error) {
      case error {
        best_before_date.Empty ->
          service.ServiceError(
            service.E400xBadRequest,
            "best_before_date is required",
          )
        best_before_date.InvalidFormat ->
          service.ServiceError(
            service.E400xBadRequest,
            "best_before_date must use format YYYY-MM-DD",
          )
        best_before_date.InvalidDate ->
          service.ServiceError(
            service.E400xBadRequest,
            "best_before_date is not a valid calendar date",
          )
      }
    }),
  )

  remove_stock_item.execute(
    remove_stock_item.Command(
      product_id: id,
      best_before_date: item_best_before_date,
    ),
    context.remove_stock_item_port,
  )
  |> result.map(map_response)
  |> result.map_error(map_error)
}
