import application/page_limit
import application/page_offset
import domain/products/product
import gleam/option.{type Option}

pub type Error {
  DatabaseFailure
  InvalidData
}

pub type ListResult {
  ListResult(items: List(product.T), total: Int)
}

pub type Params {
  Params(
    offset: page_offset.T,
    limit: page_limit.T,
    parent_product_id: Option(product.Id),
  )
}

pub type T {
  T(list: fn(Params) -> Result(ListResult, Error))
}
