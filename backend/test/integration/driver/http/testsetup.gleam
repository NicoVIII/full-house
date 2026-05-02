import application/commands/create_product
import application/commands/delete_product
import composition
import full_house
import wisp

fn mock_app_context() -> composition.AppContext {
  composition.AppContext(
    get_product_port: fn(_) { panic as "not mocked" },
    list_products_port: fn(_, _) { panic as "not mocked" },
    create_product_ports: create_product.Ports(
      does_product_exist: fn(_) { panic as "not mocked" },
      create: fn(_) { panic as "not mocked" },
    ),
    delete_product_ports: delete_product.Ports(
      get_deletion_properties: fn(_) { panic as "not mocked" },
      delete: fn(_) { panic as "not mocked" },
      load_product: fn(_) { panic as "not mocked" },
    ),
    list_stock_items_port: fn(_, _) { panic as "not mocked" },
  )
}

pub fn build_handler(
  mock_context: fn(composition.AppContext) -> composition.AppContext,
) -> fn(wisp.Request) -> wisp.Response {
  mock_app_context()
  |> mock_context
  |> full_house.build_handler
}
