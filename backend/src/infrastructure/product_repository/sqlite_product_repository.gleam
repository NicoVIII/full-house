import application/page_limit
import application/page_offset
import application/ports/product_repository
import domain/basics/uuid
import domain/product
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import sqlight

fn list_products(
  connection: sqlight.Connection,
  params: product_repository.ListParams,
) -> Result(product_repository.ListResult, Nil) {
  let product_repository.ListParams(offset:, limit:) = params

  use rows <- result.try(
    sqlight.query(
      "
      select id, name, parent_product_id
      from products
      order by name
      limit ? offset ?
      ",
      on: connection,
      with: [
        sqlight.int(page_limit.value(limit)),
        sqlight.int(page_offset.value(offset)),
      ],
      expecting: product_row_decoder(),
    )
    |> result.map_error(fn(_) { Nil }),
  )

  use items <- result.try(list.try_map(over: rows, with: map_product_row))

  use totals <- result.try(
    sqlight.query(
      "select count(*) from products",
      on: connection,
      with: [],
      expecting: total_decoder(),
    )
    |> result.map_error(fn(_) { Nil }),
  )

  let assert [total] = totals

  Ok(product_repository.ListResult(items: items, total: total))
}

fn product_row_decoder() -> decode.Decoder(#(String, String, Option(String))) {
  {
    use id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.string)
    use parent_id <- decode.field(2, decode.optional(decode.string))
    decode.success(#(id, name, parent_id))
  }
}

fn total_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

fn map_product_row(
  row: #(String, String, Option(String)),
) -> Result(product.T, Nil) {
  let #(id_raw, name, parent_id_raw) = row

  use id <- result.try(uuid.new(id_raw) |> result.map(product.ProductId))
  use parent_id <- result.try(map_parent_id(parent_id_raw))

  Ok(product.Product(id: id, name: name, parent_product_id: parent_id))
}

fn map_parent_id(
  parent_id_raw: Option(String),
) -> Result(Option(product.Id), Nil) {
  case parent_id_raw {
    None -> Ok(None)
    Some(value) ->
      uuid.new(value)
      |> result.map(product.ProductId)
      |> result.map(Some)
  }
}

pub fn new(connection: sqlight.Connection) -> product_repository.T {
  product_repository.T(list: fn(params) { list_products(connection, params) })
}
