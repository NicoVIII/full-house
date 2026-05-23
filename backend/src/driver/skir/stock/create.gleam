import application/commands/create_stock_item
import application/shared/infrastructure_error
import common/product_id
import common/uuid
import composition
import domain/stock_items/stock_item
import driver/skirout/stock
import gleam/result
import skir_client/service

fn map_error(error: create_stock_item.Error) -> service.ServiceError {
  case error {
    create_stock_item.ProductDoesNotExist ->
      service.ServiceError(
        service.E400xBadRequest,
        "product_id does not reference an existing product",
      )
    create_stock_item.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

fn map_stock_item(item: stock_item.T) -> stock.StockItem {
  let stock_item.StockItem(id, item_product_id) = item
  stock.stock_item_new(uuid.value(id), product_id.value(item_product_id))
}

pub fn handle(
  request: stock.CreateStockItemRequest,
  context: composition.AppContext,
) -> Result(stock.StockItem, service.ServiceError) {
  use id <- result.try(
    product_id.new(request.product_id)
    |> result.map_error(fn(_) {
      service.ServiceError(service.E400xBadRequest, "product id is invalid")
    }),
  )

  create_stock_item.execute(
    create_stock_item.Command(product_id: id),
    context.create_stock_item_ports,
  )
  |> result.map(map_stock_item)
  |> result.map_error(map_error)
}
