import application/commands/delete_product
import composition
import gleam/function
import gleam/http
import gleam/option.{None}
import gleam/string
import integration/create
import integration/driver/http/testsetup
import wisp/simulate

const test_id = "018f4e1a-0000-7000-8000-000000000002"

fn prepare_handler(
  mock_ports: fn(delete_product.Ports) -> delete_product.Ports,
) {
  testsetup.build_handler(fn(ctx) {
    composition.AppContext(
      ..ctx,
      delete_product_ports: mock_ports(ctx.delete_product_ports),
    )
  })
}

pub fn delete_product_returns_204_test() {
  let handler =
    prepare_handler(fn(_) {
      delete_product.Ports(
        get_deletion_properties: fn(_) {
          Ok(delete_product.DeletionProperties(
            has_stock_items: False,
            has_children: False,
          ))
        },
        delete: fn(_) { Ok(Nil) },
        load_product: fn(_id) {
          Ok(create.product(id: test_id, name: "Latte", parent_id: None))
        },
      )
    })
  let request = simulate.request(http.Delete, "/api/v1/products/" <> test_id)

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 204
  assert body == ""
}

pub fn delete_product_with_invalid_uuid_returns_400_test() {
  let handler = prepare_handler(function.identity)
  let request = simulate.request(http.Delete, "/api/v1/products/not-a-uuid")

  let response = handler(request)

  assert response.status == 400
}

pub fn delete_product_not_found_returns_404_test() {
  let handler =
    prepare_handler(fn(ports) {
      delete_product.Ports(..ports, load_product: fn(_id) {
        Error(delete_product.LoadProductNotFound)
      })
    })
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000999",
    )

  let response = handler(request)

  assert response.status == 404
}

pub fn delete_product_with_stock_items_returns_409_test() {
  let handler =
    prepare_handler(fn(ports) {
      delete_product.Ports(
        ..ports,
        get_deletion_properties: fn(_) {
          Ok(delete_product.DeletionProperties(
            has_stock_items: True,
            has_children: False,
          ))
        },
        load_product: fn(_id) {
          Ok(create.product(id: test_id, name: "Latte", parent_id: None))
        },
      )
    })
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000001",
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 409
  assert string.contains(body, "\"error\":\"conflict\"")
}

pub fn delete_product_with_child_products_returns_409_test() {
  let handler =
    prepare_handler(fn(ports) {
      delete_product.Ports(
        ..ports,
        get_deletion_properties: fn(_) {
          Ok(delete_product.DeletionProperties(
            has_stock_items: False,
            has_children: True,
          ))
        },
        load_product: fn(_id) {
          Ok(create.product(id: test_id, name: "Latte", parent_id: None))
        },
      )
    })
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000003",
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 409
  assert string.contains(body, "\"error\":\"conflict\"")
}
