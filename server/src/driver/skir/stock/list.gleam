import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/paging
import application/queries/common/stock_item_query_model
import application/queries/list_stock_items
import driver/skirout/stock_items/queries
import gleam/list
import gleam/result
import skir_client/service

fn validate_limit(limit: Int) -> Result(page_limit.T, service.ServiceError) {
  case limit {
    0 -> Ok(page_limit.default())
    _ ->
      page_limit.new(limit)
      |> result.map_error(fn(error) {
        case error {
          page_limit.GreaterThanZero ->
            service.ServiceError(
              service.E400xBadRequest,
              "Invalid limit parameter: must be greater than 0",
            )
          page_limit.LessThanOrEqualToMax ->
            service.ServiceError(
              service.E400xBadRequest,
              "Invalid limit parameter: must be between 1 and 100",
            )
        }
      })
  }
}

fn validate_offset(offset: Int) -> Result(page_offset.T, service.ServiceError) {
  page_offset.new(offset)
  |> result.map_error(fn(_) {
    service.ServiceError(
      service.E400xBadRequest,
      "Invalid offset parameter: must be greater than or equal to 0",
    )
  })
}

fn map_stock_summary(model: stock_item_query_model.T) -> queries.StockSummary {
  queries.stock_summary_new(
    model.best_before_date,
    model.product_id,
    model.product_name,
    model.quantity,
  )
}

fn map_response(response: list_stock_items.Response) -> queries.StockItemList {
  let paging.Response(data, total, paging_params) = response

  queries.stock_item_list_new(
    list.map(data, map_stock_summary),
    page_limit.value(paging_params.limit),
    page_offset.value(paging_params.offset),
    total,
  )
}

pub fn handle(
  request: queries.ListStockItemsRequest,
  port: list_stock_items.ListStockItemsPort,
) -> Result(queries.StockItemList, service.ServiceError) {
  use limit <- result.try(validate_limit(request.limit))
  use offset <- result.try(validate_offset(request.offset))

  list_stock_items.execute(paging.Params(limit: limit, offset: offset), port:)
  |> result.map(map_response)
  |> result.map_error(fn(_error) {
    service.ServiceError(
      service.E500xInternalServerError,
      "infrastructure error",
    )
  })
}
