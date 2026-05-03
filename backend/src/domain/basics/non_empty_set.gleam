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

pub fn insert(into items: T(member), this element: member) -> T(member) {
  NonEmptySet(set.insert(items.inner, element))
}

pub fn from_list(items: List(member)) -> Result(T(member), FromListError) {
  case items {
    [] -> Error(EmptyList)
    _ -> Ok(NonEmptySet(set.from_list(items)))
  }
}

pub fn to_list(items: T(member)) -> List(member) {
  set.to_list(items.inner)
}
