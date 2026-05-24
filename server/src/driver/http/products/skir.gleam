import application/queries/common/product_query_model
import driver/http/skir
import driver/http/wire_format
import driver/skirout/products/queries
import wisp

pub fn map_product(p: product_query_model.T) -> queries.Product {
  queries.product_new(
    p.barcodes,
    p.children_ids,
    p.id,
    p.name,
    p.parent_product_id,
  )
}

pub fn encode_product(
  response: wisp.Response,
  p: product_query_model.T,
  format: wire_format.T,
) -> wisp.Response {
  let product = map_product(p)
  skir.encode(response, product, queries.product_serializer(), format)
}
