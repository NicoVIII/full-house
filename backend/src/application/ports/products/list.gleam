import application/page_limit
import application/page_offset
import domain/product

pub type Error {
  DatabaseFailure
  InvalidData
}

pub type ListResult {
  ListResult(items: List(product.T), total: Int)
}

pub type Params {
  Params(offset: page_offset.T, limit: page_limit.T)
}

pub type T {
  T(list: fn(Params) -> Result(ListResult, Error))
}
