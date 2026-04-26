import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn hello_world_test() {
  let name = "Joe"

  let greeting = "Hello, " <> name <> "!"
  let expected = "Hello, Joe!"

  assert greeting == expected
}
