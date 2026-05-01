import application/queries/page_limit
import application/queries/page_offset
import domain/products/product

pub type StockSummary {
  StockSummary(product_id: product.Id, product_name: String, quantity: Int)
}

pub type ListResult {
  ListResult(items: List(StockSummary), total: Int)
}

pub type ListParams {
  ListParams(offset: page_offset.T, limit: page_limit.T)
}

pub type T {
  T(list: fn(ListParams) -> Result(ListResult, Nil))
}
