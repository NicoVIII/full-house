import application/queries/common/stock_item_query_model
import infrastructure/adapter/queries/list_stock_items/list_stock_items_adapter
import integration/create
import sqlight

fn setup_in_memory_database() -> sqlight.Connection {
  let assert Ok(connection) = sqlight.open(":memory:")
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on", on: connection)
  let assert Ok(_) =
    sqlight.exec(
      "
      create table products (
        id text primary key,
        name text not null,
        parent_product_id text references products(id)
      );

      create table stock_items (
        id text primary key,
        product_id text not null references products(id)
      );

      insert into products (id, name, parent_product_id) values
        ('018f4e1a-0000-7000-8000-000000000001', 'Espresso', null),
        ('018f4e1a-0000-7000-8000-000000000002', 'Cappuccino', null),
        ('018f4e1a-0000-7000-8000-000000000003', 'Latte', null);

      insert into stock_items (id, product_id) values
        ('018f4e1a-1000-7000-8000-000000000001', '018f4e1a-0000-7000-8000-000000000001'),
        ('018f4e1a-1000-7000-8000-000000000002', '018f4e1a-0000-7000-8000-000000000001'),
        ('018f4e1a-1000-7000-8000-000000000003', '018f4e1a-0000-7000-8000-000000000002');
      ",
      on: connection,
    )

  connection
}

pub fn sqlite_stock_adapter_returns_aggregated_quantities_test() {
  let connection = setup_in_memory_database()
  let port = list_stock_items_adapter.new(connection)

  let assert Ok(result) = port(create.paging_params(10, 0))

  let assert [first, ..] = result.data
  let stock_item_query_model.StockItemQueryModel(product_name:, quantity:, ..) =
    first

  assert result.total == 2
  assert product_name == "Cappuccino"
  assert quantity == 1
}

pub fn sqlite_stock_adapter_supports_pagination_test() {
  let connection = setup_in_memory_database()
  let port = list_stock_items_adapter.new(connection)

  let assert Ok(result) = port(create.paging_params(1, 1))

  let assert [first] = result.data
  let stock_item_query_model.StockItemQueryModel(product_name:, quantity:, ..) =
    first

  assert result.total == 2
  assert product_name == "Espresso"
  assert quantity == 2
}
