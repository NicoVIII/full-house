import application/ports/products/create as create_product_port
import domain/basics/uuid
import domain/product
import domain/product_name
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn map_create_sqlight_error(_: sqlight.Error) -> create_product_port.Error {
  create_product_port.DatabaseFailure
}

fn map_create_error(error: sqlight.Error) -> create_product_port.Error {
  case error {
    sqlight.SqlightError(code: sqlight.ConstraintForeignkey, ..) ->
      create_product_port.ParentProductNotFound
    _ -> create_product_port.DatabaseFailure
  }
}

fn product_row_decoder() -> decode.Decoder(#(String, String, Option(String))) {
  {
    use id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.string)
    use parent_id <- decode.field(2, decode.optional(decode.string))
    decode.success(#(id, name, parent_id))
  }
}

fn parent_product_id_value(parent_id: Option(product.Id)) -> sqlight.Value {
  sqlight.nullable(
    fn(product_id) { sqlight.text(shared.product_id_value(product_id)) },
    parent_id,
  )
}

fn ensure_parent_exists(
  connection: sqlight.Connection,
  parent_id: Option(product.Id),
) -> Result(Nil, create_product_port.Error) {
  case parent_id {
    None -> Ok(Nil)
    Some(parent_product_id) -> {
      use totals <- result.try(
        sqlight.query(
          "
          select count(*)
          from products
          where id = ?
          ",
          on: connection,
          with: [sqlight.text(shared.product_id_value(parent_product_id))],
          expecting: shared.total_decoder(),
        )
        |> result.map_error(map_create_sqlight_error),
      )

      let assert [count] = totals
      case count == 0 {
        True -> Error(create_product_port.ParentProductNotFound)
        False -> Ok(Nil)
      }
    }
  }
}

fn create_product(
  connection: sqlight.Connection,
  new_product: product.T,
) -> Result(Nil, create_product_port.Error) {
  let product.Product(id:, name:, parent_product_id:) = new_product
  let product.ProductId(uid) = id

  use _ <- result.try(ensure_parent_exists(connection, parent_product_id))

  use _ <- result.try(
    sqlight.query(
      "
      insert into products (id, name, parent_product_id)
      values (?, ?, ?)
      returning id, name, parent_product_id
      ",
      on: connection,
      with: [
        sqlight.text(uuid.value(uid)),
        sqlight.text(product_name.value(name)),
        parent_product_id_value(parent_product_id),
      ],
      expecting: product_row_decoder(),
    )
    |> result.map_error(map_create_error),
  )

  Ok(Nil)
}

pub fn new(connection: sqlight.Connection) -> create_product_port.T {
  create_product_port.T(create: fn(new_product) {
    create_product(connection, new_product)
  })
}
