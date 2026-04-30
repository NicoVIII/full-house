import driver/http/products/handler as products_handler
import infrastructure/product_repository/sqlite_product_repository/create_port as product_create_adapter
import infrastructure/product_repository/sqlite_product_repository/delete_port as product_delete_adapter
import infrastructure/product_repository/sqlite_product_repository/deletion_references_port as product_deletion_references_adapter
import infrastructure/product_repository/sqlite_product_repository/list_port as product_list_adapter
import infrastructure/product_repository/sqlite_product_repository/validate_parent_product_port as product_validate_parent_adapter
import sqlight
import wisp

pub fn compose(
  connection: sqlight.Connection,
) -> fn(wisp.Request) -> wisp.Response {
  let product_list_repo = product_list_adapter.new(connection)
  let product_validate_parent_repo =
    product_validate_parent_adapter.new(connection)
  let product_create_repo = product_create_adapter.new(connection)
  let product_deletion_references_repo =
    product_deletion_references_adapter.new(connection)
  let product_delete_repo = product_delete_adapter.new(connection)

  fn(request) {
    products_handler.handle(
      request,
      product_list_repo,
      product_validate_parent_repo,
      product_create_repo,
      product_deletion_references_repo,
      product_delete_repo,
    )
  }
}
