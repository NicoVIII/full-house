import application/queries/page_limit
import application/queries/page_offset
import application/queries/ports/stock_repository
import domain/basics/uuid
import domain/products/product
import gleam/dynamic/decode
import gleam/list
import gleam/result
import sqlight

fn list_stock(
  connection: sqlight.Connection,
  params: stock_repository.ListParams,
) -> Result(stock_repository.ListResult, Nil) {
  let stock_repository.ListParams(offset:, limit:) = params

  use rows <- result.try(
    sqlight.query(
      "
      select p.id, p.name, count(s.id)
      from stock_items as s
      inner join products as p on p.id = s.product_id
      group by p.id, p.name
      order by p.name
      limit ? offset ?
      ",
      on: connection,
      with: [
        sqlight.int(page_limit.value(limit)),
        sqlight.int(page_offset.value(offset)),
      ],
      expecting: stock_row_decoder(),
    )
    |> result.map_error(fn(_) { Nil }),
  )

  use items <- result.try(list.try_map(over: rows, with: map_stock_row))

  use totals <- result.try(
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
      expecting: total_decoder(),
    )
    |> result.map_error(fn(_) { Nil }),
  )

  let assert [total] = totals

  Ok(stock_repository.ListResult(items: items, total: total))
}

fn stock_row_decoder() -> decode.Decoder(#(String, String, Int)) {
  {
    use product_id <- decode.field(0, decode.string)
    use product_name <- decode.field(1, decode.string)
    use quantity <- decode.field(2, decode.int)
    decode.success(#(product_id, product_name, quantity))
  }
}

fn total_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

fn map_stock_row(
  row: #(String, String, Int),
) -> Result(stock_repository.StockSummary, Nil) {
  let #(product_id_raw, product_name, quantity) = row

  use product_id <- result.try(
    uuid.new(product_id_raw)
    |> result.map(product.ProductId),
  )

  Ok(stock_repository.StockSummary(
    product_id: product_id,
    product_name: product_name,
    quantity: quantity,
  ))
}

pub fn new(connection: sqlight.Connection) -> stock_repository.T {
  stock_repository.T(list: fn(params) { list_stock(connection, params) })
}
