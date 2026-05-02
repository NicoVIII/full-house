import application/queries/common/product_query_model

pub type T {
  StockItemQueryModel(
    product_id: product_query_model.Id,
    product_name: String,
    quantity: Int,
  )
}
