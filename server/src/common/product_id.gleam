import common/uuid_v7
import gleam/result

pub opaque type T {
  ProductId(value: uuid_v7.T)
}

pub fn new(raw_id: String) -> Result(T, Nil) {
  uuid_v7.new(raw_id)
  |> result.map(ProductId)
}

pub fn to_value(product_id: T) -> String {
  let ProductId(uid) = product_id
  uuid_v7.to_value(uid)
}
