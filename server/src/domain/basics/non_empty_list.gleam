import gleam/list

pub opaque type T(member) {
  NonEmptyList(inner: List(member))
}

pub type FromListError {
  EmptyList
}

pub fn new(element: member) -> T(member) {
  NonEmptyList([element])
}

pub fn fold(
  over list: T(a),
  from initial: acc,
  with fun: fn(acc, a) -> acc,
) -> acc {
  list.fold(list.inner, initial, fun)
}

pub fn first(list: T(member)) -> member {
  let assert Ok(first) = list.first(list.inner)
  first
}

pub fn prepend(into items: T(member), this element: member) -> T(member) {
  NonEmptyList([element, ..items.inner])
}

pub fn from_list(items: List(member)) -> Result(T(member), FromListError) {
  case items {
    [] -> Error(EmptyList)
    elements -> Ok(NonEmptyList(elements))
  }
}

pub fn to_list(items: T(member)) -> List(member) {
  items.inner
}
