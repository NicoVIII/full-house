import application/commands/products/update/ports
import common/product_id
import domain/products/product
import gleam/result
import infrastructure/commands/repository/commands/product_repository
import sqlight

fn get_product(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(product.T, ports.LoadProductError) {
  product_repository.get(id, connection)
  |> result.map_error(fn(error) {
    case error {
      product_repository.NotFound -> ports.LoadProductNotFound
      product_repository.InfrastructureError(e) ->
        ports.LoadProductInfrastructureError(e)
    }
  })
}

pub fn new(connection: sqlight.Connection) -> ports.LoadProduct {
  fn(id) { get_product(id, connection) }
}
