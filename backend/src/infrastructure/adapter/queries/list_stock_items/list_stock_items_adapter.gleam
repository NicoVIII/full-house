import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/paging
import application/queries/common/stock_item_query_model
import application/queries/list_stock_items
import application/shared/infrastructure_error
import gleam/dynamic/decode
import gleam/result
import infrastructure/adapter/decoder
import sqlight

fn query_total(
  connection: sqlight.Connection,
) -> Result(Int, infrastructure_error.T) {
  let total_query_result =
    sqlight.query(
      "
      select count(*)
      from (
        select p.id
        from stock_items as s
        inner join products as p on p.id = s.product_id
        group by p.id
      ) as stocked_products
      ",
      on: connection,
      with: [],
      expecting: decoder.count(),
    )

  case total_query_result {
    Ok([total]) -> Ok(total)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result format for total count query"
  }
}

fn stock_item_decoder() -> decode.Decoder(stock_item_query_model.T) {
  use product_id <- decode.field(0, decode.string)
  use product_name <- decode.field(1, decode.string)
  use quantity <- decode.field(2, decode.int)
  decode.success(stock_item_query_model.StockItemQueryModel(
    product_id: product_id,
    product_name: product_name,
    quantity: quantity,
  ))
}

fn query_stock_item_list(
  paging_params: paging.Params,
  connection: sqlight.Connection,
) -> Result(List(stock_item_query_model.T), infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT p.id, p.name, count(s.id)
      FROM stock_items AS s
      INNER JOIN products AS p ON p.id = s.product_id
      GROUP BY p.id, p.name
      ORDER BY p.name
      LIMIT ? OFFSET ?
      ",
      on: connection,
      with: [
        sqlight.int(page_limit.value(paging_params.limit)),
        sqlight.int(page_offset.value(paging_params.offset)),
      ],
      expecting: stock_item_decoder(),
    )

  case query_result {
    Ok(items) -> Ok(items)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

fn list_stock(
  paging_params: paging.Params,
  connection: sqlight.Connection,
) -> Result(list_stock_items.Response, infrastructure_error.T) {
  use total <- result.try(query_total(connection))
  use model_list <- result.try(query_stock_item_list(paging_params, connection))

  Ok(paging.Response(data: model_list, total:, paging_params:))
}

pub fn new(
  connection: sqlight.Connection,
) -> list_stock_items.ListStockItemsPort {
  fn(paging_params) { list_stock(paging_params, connection) }
}
