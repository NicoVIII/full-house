import application/commands/products/create/ports as create_product_ports
import application/commands/products/delete/ports as delete_product_ports
import application/commands/products/update/ports as update_product_ports
import application/commands/stock_items/create/ports as create_stock_item_ports
import application/commands/stock_items/delete/ports as delete_stock_item_ports
import application/queries/get_product
import application/queries/get_product_by_barcode
import application/queries/list_products
import application/queries/list_stock_items
import infrastructure/commands/adapter/barcode_assignment_adapter
import infrastructure/commands/adapter/product_existence_adapter
import infrastructure/commands/adapter/products/create/create_adapter as create_product_adapter
import infrastructure/commands/adapter/products/delete/delete_adapter as delete_product_adapter
import infrastructure/commands/adapter/products/delete/has_children_adapter
import infrastructure/commands/adapter/products/delete/has_stock_items_adapter
import infrastructure/commands/adapter/products/delete/load_product_adapter as products_delete_load_product_adapter
import infrastructure/commands/adapter/products/update/load_product_adapter as products_update_load_product_adapter
import infrastructure/commands/adapter/products/update/update_adapter as update_product_adapter
import infrastructure/commands/adapter/stock_items/create/create_adapter as stock_item_create_adapter
import infrastructure/commands/adapter/stock_items/delete/delete_adapter as remove_stock_item_adapter
import infrastructure/queries/adapter/get_product/get_product_adapter
import infrastructure/queries/adapter/get_product_by_barcode/get_product_by_barcode_adapter
import infrastructure/queries/adapter/list_products/list_products_adapter
import infrastructure/queries/adapter/list_stock_items/list_stock_items_adapter
import sqlight

pub type AppProductsCommandContext {
  AppProductsCommandContext(
    create_ports: create_product_ports.T,
    delete_ports: delete_product_ports.T,
    update_ports: update_product_ports.T,
  )
}

pub type AppProductsQueryContext {
  AppProductsQueryContext(
    get_port: get_product.GetProductPort,
    get_by_barcode_port: get_product_by_barcode.GetProductByBarcodePort,
    list_port: list_products.ListProductsPort,
  )
}

pub type AppProductsContext {
  AppProductsContext(
    command_context: AppProductsCommandContext,
    query_context: AppProductsQueryContext,
  )
}

pub type AppStockItemsCommandContext {
  AppStockItemsCommandContext(
    create_ports: create_stock_item_ports.T,
    delete_ports: delete_stock_item_ports.Delete,
  )
}

pub type AppStockItemsQueryContext {
  AppStockItemsQueryContext(list_port: list_stock_items.ListStockItemsPort)
}

pub type AppStockItemsContext {
  AppStockItemsContext(
    command_context: AppStockItemsCommandContext,
    query_context: AppStockItemsQueryContext,
  )
}

/// Holds all dependencies for the application layer, to be passed to handlers and other entry points.
pub type AppContext {
  AppContext(
    product_context: AppProductsContext,
    stock_item_context: AppStockItemsContext,
  )
}

pub fn compose_products_command_context(
  db_connection: sqlight.Connection,
) -> AppProductsCommandContext {
  AppProductsCommandContext(
    create_ports: create_product_ports.Ports(
      create: create_product_adapter.new(db_connection),
      does_product_exist: product_existence_adapter.new(db_connection),
      is_barcode_assigned: barcode_assignment_adapter.new(db_connection),
    ),
    delete_ports: delete_product_ports.Ports(
      delete: delete_product_adapter.new(db_connection),
      has_children: has_children_adapter.new(db_connection),
      has_stock_items: has_stock_items_adapter.new(db_connection),
      load_product: products_delete_load_product_adapter.new(db_connection),
    ),
    update_ports: update_product_ports.Ports(
      does_product_exist: product_existence_adapter.new(db_connection),
      load_product: products_update_load_product_adapter.new(db_connection),
      is_barcode_assigned: barcode_assignment_adapter.new(db_connection),
      update: update_product_adapter.new(db_connection),
    ),
  )
}

pub fn compose_products_query_context(
  db_connection: sqlight.Connection,
) -> AppProductsQueryContext {
  AppProductsQueryContext(
    get_port: get_product_adapter.new(db_connection),
    get_by_barcode_port: get_product_by_barcode_adapter.new(db_connection),
    list_port: list_products_adapter.new(db_connection),
  )
}

pub fn compose_products_context(
  db_connection: sqlight.Connection,
) -> AppProductsContext {
  AppProductsContext(
    command_context: compose_products_command_context(db_connection),
    query_context: compose_products_query_context(db_connection),
  )
}

pub fn compose_stock_items_command_context(
  db_connection: sqlight.Connection,
) -> AppStockItemsCommandContext {
  AppStockItemsCommandContext(
    create_ports: create_stock_item_ports.Ports(
      create: stock_item_create_adapter.new(db_connection),
      does_product_exist: product_existence_adapter.new(db_connection),
    ),
    delete_ports: remove_stock_item_adapter.new(db_connection),
  )
}

pub fn compose_stock_items_query_context(
  db_connection: sqlight.Connection,
) -> AppStockItemsQueryContext {
  AppStockItemsQueryContext(list_port: list_stock_items_adapter.new(
    db_connection,
  ))
}

pub fn compose_stock_items_context(
  db_connection: sqlight.Connection,
) -> AppStockItemsContext {
  AppStockItemsContext(
    command_context: compose_stock_items_command_context(db_connection),
    query_context: compose_stock_items_query_context(db_connection),
  )
}

pub fn compose_app_context(db_connection: sqlight.Connection) -> AppContext {
  AppContext(
    product_context: compose_products_context(db_connection),
    stock_item_context: compose_stock_items_context(db_connection),
  )
}
