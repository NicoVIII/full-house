import application/commands/create_product
import application/commands/create_stock_item
import application/commands/delete_product
import application/commands/remove_stock_item
import application/commands/update_product_barcodes
import application/queries/get_product
import application/queries/get_product_by_barcode
import application/queries/list_products
import application/queries/list_stock_items
import composition
import full_house
import gleam/erlang/process
import wisp

fn mock_app_context() -> composition.AppContext {
  composition.AppContext(
    get_product_port: fn(_) { panic as "not mocked" },
    list_products_port: fn(_) { panic as "not mocked" },
    create_product_ports: create_product.Ports(
      does_product_exist: fn(_) { panic as "not mocked" },
      create: fn(_) { panic as "not mocked" },
    ),
    delete_product_ports: delete_product.Ports(
      get_deletion_properties: fn(_) { panic as "not mocked" },
      delete: fn(_) { panic as "not mocked" },
      load_product: fn(_) { panic as "not mocked" },
    ),
    update_product_barcodes_port: fn(_, _, _) { panic as "not mocked" },
    remove_stock_item_port: fn(_, _) { panic as "not mocked" },
    get_product_by_barcode_port: fn(_) { panic as "not mocked" },
    create_stock_item_ports: create_stock_item.Ports(
      does_product_exist: fn(_) { panic as "not mocked" },
      create: fn(_) { panic as "not mocked" },
    ),
    list_stock_items_port: fn(_) { panic as "not mocked" },
  )
}

pub fn build_handler(
  mock_context: fn(composition.AppContext) -> composition.AppContext,
) -> fn(wisp.Request) -> wisp.Response {
  mock_app_context()
  |> mock_context
  |> full_house.build_handler(process.new_name("test_mock"))
}

pub fn build_handler_with_create_stock_item_ports(
  mock_ports: fn(create_stock_item.Ports) -> create_stock_item.Ports,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(
      ..ctx,
      create_stock_item_ports: mock_ports(ctx.create_stock_item_ports),
    )
  })
}

pub fn build_handler_with_create_product_ports(
  mock_ports: fn(create_product.Ports) -> create_product.Ports,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(
      ..ctx,
      create_product_ports: mock_ports(ctx.create_product_ports),
    )
  })
}

pub fn build_handler_with_get_product_port(
  mock_port: get_product.GetProductPort,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(..ctx, get_product_port: mock_port)
  })
}

pub fn build_handler_with_get_product_by_barcode_port(
  mock_port: get_product_by_barcode.GetProductByBarcodePort,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(..ctx, get_product_by_barcode_port: mock_port)
  })
}

pub fn build_handler_with_list_products_port(
  mock_port: list_products.ListProductsPort,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(..ctx, list_products_port: mock_port)
  })
}

pub fn build_handler_with_delete_product_ports(
  mock_ports: fn(delete_product.Ports) -> delete_product.Ports,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(
      ..ctx,
      delete_product_ports: mock_ports(ctx.delete_product_ports),
    )
  })
}

pub fn build_handler_with_update_product_barcodes_port(
  mock_port: update_product_barcodes.UpdateBarcodesPort,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(..ctx, update_product_barcodes_port: mock_port)
  })
}

pub fn build_handler_with_list_stock_items_port(
  mock_port: list_stock_items.ListStockItemsPort,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(..ctx, list_stock_items_port: mock_port)
  })
}

pub fn build_handler_with_remove_stock_item_port(
  mock_port: remove_stock_item.RemovePort,
) -> fn(wisp.Request) -> wisp.Response {
  build_handler(fn(ctx) {
    composition.AppContext(..ctx, remove_stock_item_port: mock_port)
  })
}
