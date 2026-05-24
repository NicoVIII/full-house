import domain/basics/non_empty_list
import gleam/list
import gleam/result
import gleam/set

pub opaque type T(member) {
  NonEmptySet(inner: set.Set(member))
}

pub type FromListError {
  EmptyList
}

pub fn new(element: member) -> T(member) {
  NonEmptySet(set.from_list([element]))
}

pub fn from_list(items: List(member)) -> Result(T(member), FromListError) {
  case items {
    [] -> Error(EmptyList)
    _ -> Ok(NonEmptySet(set.from_list(items)))
  }
}

pub fn insert(into items: T(member), this element: member) -> T(member) {
  NonEmptySet(set.insert(items.inner, element))
}

pub fn map(set: T(member), with fun: fn(member) -> mapped) -> T(mapped) {
  NonEmptySet(set.map(set.inner, fun))
}

pub fn try_map(
  over set: T(a),
  with fun: fn(a) -> Result(b, e),
) -> Result(T(b), e) {
  set.inner
  |> set.to_list
  |> list.try_map(fun)
  |> result.map(fn(list) { list |> set.from_list |> NonEmptySet })
}

pub fn to_list(items: T(member)) -> List(member) {
  set.to_list(items.inner)
}

pub fn to_non_empty_list(items: T(member)) -> non_empty_list.T(member) {
  let assert Ok(list) =
    items.inner
    |> set.to_list
    |> non_empty_list.from_list
  list
}

pub fn to_set(items: T(member)) -> set.Set(member) {
  items.inner
}
