import application/commands/create_product
import application/commands/create_stock_item
import application/commands/delete_product
import application/queries/get_product
import application/queries/list_products
import application/queries/list_stock_items
import infrastructure/adapter/commands/create_product/create_adapter
import infrastructure/adapter/commands/create_product/product_existence_adapter
import infrastructure/adapter/commands/create_stock_item/create_adapter as stock_item_create_adapter
import infrastructure/adapter/commands/delete_product/delete_adapter
import infrastructure/adapter/commands/delete_product/deletion_properties_adapter
import infrastructure/adapter/commands/delete_product/load_product_adapter
import infrastructure/adapter/queries/get_product/get_product_adapter
import infrastructure/adapter/queries/list_products/list_products_adapter
import infrastructure/adapter/queries/list_stock_items/list_stock_items_adapter
import sqlight

/// Holds all dependencies for the application layer, to be passed to handlers and other entry points.
pub type AppContext {
  AppContext(
    create_product_ports: create_product.Ports,
    create_stock_item_ports: create_stock_item.Ports,
    delete_product_ports: delete_product.Ports,
    get_product_port: get_product.GetProductPort,
    list_products_port: list_products.ListProductsPort,
    list_stock_items_port: list_stock_items.ListStockItemsPort,
  )
}

pub fn compose_app_context(db_connection: sqlight.Connection) -> AppContext {
  AppContext(
    create_product_ports: create_product.Ports(
      create: create_adapter.new(db_connection),
      does_product_exist: product_existence_adapter.new(db_connection),
    ),
    create_stock_item_ports: create_stock_item.Ports(
      create: stock_item_create_adapter.new(db_connection),
      does_product_exist: product_existence_adapter.new(db_connection),
    ),
    delete_product_ports: delete_product.Ports(
      delete: delete_adapter.new(db_connection),
      get_deletion_properties: deletion_properties_adapter.new(db_connection),
      load_product: load_product_adapter.new(db_connection),
    ),
    get_product_port: get_product_adapter.new(db_connection),
    list_products_port: list_products_adapter.new(db_connection),
    list_stock_items_port: list_stock_items_adapter.new(db_connection),
  )
}
