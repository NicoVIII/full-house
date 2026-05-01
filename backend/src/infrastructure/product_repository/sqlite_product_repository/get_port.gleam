import application/queries/ports/get as get_product_port
import domain/basics/uuid
import domain/products/product
import domain/products/product_name
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

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
) -> Result(Option(product.Id), get_product_port.Error) {
  case parent_id_raw {
    None -> Ok(None)
    Some(value) ->
      uuid.new(value)
      |> result.map(product.ProductId)
      |> result.map(Some)
      |> result.map_error(fn(_) { get_product_port.InvalidData })
  }
}

fn map_product_row(
  row: #(String, String, Option(String)),
) -> Result(product.T, get_product_port.Error) {
  let #(id_raw, raw_name, parent_id_raw) = row

  use id <- result.try(
    uuid.new(id_raw)
    |> result.map(product.ProductId)
    |> result.map_error(fn(_) { get_product_port.InvalidData }),
  )
  use parent_id <- result.try(map_parent_id(parent_id_raw))
  use name <- result.try(
    product_name.from_user_input(raw_name)
    |> result.map_error(fn(_) { get_product_port.InvalidData }),
  )

  Ok(product.Product(id: id, name: name, parent_product_id: parent_id))
}

fn map_get_error(_: sqlight.Error) -> get_product_port.Error {
  get_product_port.DatabaseFailure
}

fn get_product(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(product.T, get_product_port.Error) {
  use rows <- result.try(
    sqlight.query(
      "
      select id, name, parent_product_id
      from products
      where id = ?
      ",
      on: connection,
      with: [sqlight.text(shared.product_id_value(product_id))],
      expecting: product_row_decoder(),
    )
    |> result.map_error(map_get_error),
  )

  case rows {
    [row] -> map_product_row(row)
    [] -> Error(get_product_port.ProductNotFound)
    _ -> Error(get_product_port.InvalidData)
  }
}

pub fn new(connection: sqlight.Connection) -> get_product_port.T {
  get_product_port.T(get: fn(product_id) { get_product(connection, product_id) })
}
