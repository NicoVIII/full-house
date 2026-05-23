import application/queries/common/page_limit
import application/queries/common/page_offset

pub type Params {
  Params(limit: page_limit.T, offset: page_offset.T)
}

pub type Response(a) {
  Response(data: List(a), total: Int, paging_params: Params)
}
