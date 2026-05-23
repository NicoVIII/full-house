import composition
import driver/skir/product/create
import driver/skir/product/delete
import driver/skir/product/get
import driver/skir/product/list
import driver/skir/stock/create as stock_create
import driver/skir/stock/list as stock_list
import driver/skir/stock/remove as stock_remove
import driver/skirout/product
import driver/skirout/stock
import gleam/erlang/process
import skir_client/service

pub type RpcService =
  service.Service(Nil, composition.AppContext, Nil)

fn simplify_handle(
  handler: fn(a, composition.AppContext) -> Result(b, service.ServiceError),
) {
  fn(request: a, _: Nil, context: composition.AppContext) -> #(
    Result(b, service.ServiceError),
    Nil,
    Nil,
  ) {
    let result = handler(request, context)
    #(result, Nil, Nil)
  }
}

pub fn make_service() -> RpcService {
  service.new(empty_message: Nil)
  |> service.add_method(
    product.create_product_method(),
    simplify_handle(create.handle),
  )
  |> service.add_method(
    product.get_product_method(),
    simplify_handle(get.handle),
  )
  |> service.add_method(
    product.list_products_method(),
    simplify_handle(list.handle),
  )
  |> service.add_method(
    product.delete_product_method(),
    simplify_handle(delete.handle),
  )
  |> service.add_method(
    stock.create_stock_item_method(),
    simplify_handle(stock_create.handle),
  )
  |> service.add_method(
    stock.list_stock_items_method(),
    simplify_handle(stock_list.handle),
  )
  |> service.add_method(
    stock.remove_stock_item_method(),
    simplify_handle(stock_remove.handle),
  )
}

pub type ServerMessage {
  HandleRpc(body: String, reply: process.Subject(service.RawResponse))
}

pub type ServerName =
  process.Name(ServerMessage)

pub type ServerState {
  ServerState(service: RpcService, context: composition.AppContext)
}

fn handle_server_message(
  state: ServerState,
  message: ServerMessage,
) -> ServerState {
  case message {
    HandleRpc(body, reply) -> {
      let #(raw, _) =
        service.handle_request(state.service, body, Nil, state.context)
      process.send(reply, raw)

      state
    }
  }
}

fn server_loop(
  subject: process.Subject(ServerMessage),
  state: ServerState,
) -> Nil {
  let message = process.receive_forever(subject)
  let new_state = handle_server_message(state, message)
  server_loop(subject, new_state)
}

pub fn start_server_loop(name: ServerName, initial_state: ServerState) -> Nil {
  let assert Ok(_) = process.register(process.self(), name)
  let subject = process.named_subject(name)
  server_loop(subject, initial_state)
}
