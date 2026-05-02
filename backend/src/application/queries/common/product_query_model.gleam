import gleam/option.{type Option}

pub type Id =
  String

pub type T {
  ProductQueryModel(
    id: Id,
    name: String,
    parent_product_id: Option(Id),
    children_ids: List(Id),
  )
}
