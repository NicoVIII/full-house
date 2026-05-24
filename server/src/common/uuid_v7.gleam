import gleam/bool
import gleam/result
import youid/uuid.{type Uuid}

pub opaque type T {
  Uuid(value: Uuid)
}

@deprecated("Clients should generate ids")
pub fn generate() -> T {
  uuid.v7()
  |> Uuid
}

pub fn new(value: String) -> Result(T, Nil) {
  use uuid <- result.try(uuid.from_string(value))
  use <- bool.guard(uuid.version(uuid) != uuid.V7, Error(Nil))
  Ok(Uuid(uuid))
}

pub fn to_value(uuid: T) -> String {
  uuid.to_string(uuid.value)
}
