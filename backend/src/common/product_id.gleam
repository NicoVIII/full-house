import common/uuid
import gleam/result

pub opaque type T {
  ProductId(value: uuid.T)
}

pub fn generate() -> T {
  ProductId(uuid.generate_v7())
}

pub fn new(raw_id: String) -> Result(T, Nil) {
  uuid.new(raw_id)
  |> result.map(ProductId)
}

pub fn value(product_id: T) -> String {
  let ProductId(uid) = product_id
  uuid.value(uid)
}
