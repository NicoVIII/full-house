import gleam/set

pub opaque type T(a) {
  NonEmptySet(inner: set.Set(a))
}

pub type FromListError {
  EmptyList
}

pub fn new(element: a) -> T(a) {
  NonEmptySet(set.from_list([element]))
}

pub fn insert(items: T(a), element: a) -> T(a) {
  NonEmptySet(set.insert(items.inner, element))
}

pub fn from_list(items: List(a)) -> Result(T(a), FromListError) {
  case items {
    [] -> Error(EmptyList)
    _ -> Ok(NonEmptySet(set.from_list(items)))
  }
}

pub fn to_list(items: T(a)) -> List(a) {
  set.to_list(items.inner)
}

pub fn size(items: T(a)) -> Int {
  set.size(items.inner)
}
