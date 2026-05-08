import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/list_products
import driver/http/products/skir as product_skir
import driver/http/skir
import driver/http/wire_format
import driver/skirout/product as skir_product
import gleam/list
import wisp

pub fn map_list_products_response(
  response: wisp.Response,
  list_product_response: list_products.Response,
  format: wire_format.T,
) -> wisp.Response {
  let list_reponse =
    skir_product.product_list_response_new(
      list.map(list_product_response.data, product_skir.map_product),
      page_limit.value(list_product_response.paging_params.limit),
      page_offset.value(list_product_response.paging_params.offset),
      list_product_response.total,
    )
  response
  |> skir.encode(
    list_reponse,
    skir_product.product_list_response_serializer(),
    format,
  )
}
