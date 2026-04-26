import application/page_limit
import application/page_offset
import domain/product

pub type ListResult {
  ListResult(items: List(product.T), total: Int)
}

pub type ListParams {
  ListParams(offset: page_offset.T, limit: page_limit.T)
}

pub type T {
  T(list: fn(ListParams) -> Result(ListResult, Nil))
}
