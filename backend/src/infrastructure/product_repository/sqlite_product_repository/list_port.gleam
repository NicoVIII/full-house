import application/page_limit
import application/page_offset
import application/ports/products/list as list_product_port
import domain/basics/uuid
import domain/products/product
import domain/products/product_name
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight
import wisp

fn product_row_decoder() -> decode.Decoder(#(String, String, Option(String))) {
  {
    use id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.string)
    use parent_id <- decode.field(2, decode.optional(decode.string))
    decode.success(#(id, name, parent_id))
  }
}

fn map_parent_id(
  parent_id_raw: Option(String),
) -> Result(Option(product.Id), list_product_port.Error) {
  case parent_id_raw {
    None -> Ok(None)
    Some(value) ->
      uuid.new(value)
      |> result.map(product.ProductId)
      |> result.map(Some)
      |> result.map_error(fn(_) { list_product_port.InvalidData })
  }
}

fn map_product_row(
  row: #(String, String, Option(String)),
) -> Result(Option(product.T), list_product_port.Error) {
  let #(id_raw, raw_name, parent_id_raw) = row

  use id <- result.try(
    uuid.new(id_raw)
    |> result.map(product.ProductId)
    |> result.map_error(fn(_) { list_product_port.InvalidData }),
  )
  use parent_id <- result.try(map_parent_id(parent_id_raw))

  case product_name.from_user_input(raw_name) {
    Ok(name) ->
      Ok(
        Some(product.Product(id: id, name: name, parent_product_id: parent_id)),
      )
    Error(_) -> {
      wisp.log_warning("Skipped product " <> id_raw <> " because name is empty")
      Ok(None)
    }
  }
}

fn map_list_error(_: sqlight.Error) -> list_product_port.Error {
  list_product_port.DatabaseFailure
}

fn list_products(
  connection: sqlight.Connection,
  params: list_product_port.Params,
) -> Result(list_product_port.ListResult, list_product_port.Error) {
  let list_product_port.Params(offset:, limit:) = params

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
    |> result.map_error(map_list_error),
  )

  use mapped <- result.try(list.try_map(over: rows, with: map_product_row))
  let items =
    list.filter_map(mapped, with: fn(item) {
      case item {
        Some(product) -> Ok(product)
        None -> Error(Nil)
      }
    })

  use totals <- result.try(
    sqlight.query(
      "
      select count(*)
      from products
      where trim(name) != ''
      ",
      on: connection,
      with: [],
      expecting: shared.total_decoder(),
    )
    |> result.map_error(map_list_error),
  )

  use invalid_totals <- result.try(
    sqlight.query(
      "
      select count(*)
      from products
      where trim(name) = ''
      ",
      on: connection,
      with: [],
      expecting: shared.total_decoder(),
    )
    |> result.map_error(map_list_error),
  )

  let assert [total] = totals
  let assert [invalid_total] = invalid_totals

  case invalid_total > 0 {
    True ->
      wisp.log_warning(
        "Skipped "
        <> int.to_string(invalid_total)
        <> " product rows with empty names",
      )
    False -> Nil
  }

  Ok(list_product_port.ListResult(items: items, total: total))
}

pub fn new(connection: sqlight.Connection) -> list_product_port.T {
  list_product_port.T(list: fn(params) { list_products(connection, params) })
}
