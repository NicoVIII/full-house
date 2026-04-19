import gleam/result
import youid/uuid.{type Uuid}

pub opaque type T {
  Uuid(value: Uuid)
}

pub fn generate_v7() -> T {
  uuid.v7()
  |> Uuid
}

pub fn new(value: String) -> Result(T, Nil) {
  uuid.from_string(value)
  |> result.map(Uuid)
}

pub fn value(uuid: T) -> String {
  uuid.to_string(uuid.value)
}
