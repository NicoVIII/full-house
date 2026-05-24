import composition
import driver/skir/product/create
import driver/skir/product/delete
import driver/skir/product/get
import driver/skir/product/get_by_barcode
import driver/skir/product/list
import driver/skir/product/update
import driver/skir/stock/create as stock_create
import driver/skir/stock/delete as stock_delete
import driver/skir/stock/list as stock_list
import driver/skirout/products/commands as product_commands
import driver/skirout/products/queries as product_queries
import driver/skirout/stock_items/commands as stock_item_commands
import driver/skirout/stock_items/queries as stock_item_queries
import gleam/erlang/process
import skir_client/service

pub type RpcService =
  service.Service(Nil, composition.AppContext, Nil)

fn simplify_handle(
  handler: fn(a, ports) -> Result(b, service.ServiceError),
  port_mapper: fn(composition.AppContext) -> ports,
) {
  fn(request: a, _: Nil, context: composition.AppContext) -> #(
    Result(b, service.ServiceError),
    Nil,
    Nil,
  ) {
    let result = handler(request, port_mapper(context))
    #(result, Nil, Nil)
  }
}

pub fn make_service() -> RpcService {
  service.new(empty_message: Nil)
  |> service.add_method(
    product_commands.create_product_method(),
    simplify_handle(create.handle, fn(ctx) {
      ctx.product_context.command_context.create_ports
    }),
  )
  |> service.add_method(
    product_queries.get_product_method(),
    simplify_handle(get.handle, fn(ctx) {
      ctx.product_context.query_context.get_port
    }),
  )
  |> service.add_method(
    product_queries.list_products_method(),
    simplify_handle(list.handle, fn(ctx) {
      ctx.product_context.query_context.list_port
    }),
  )
  |> service.add_method(
    product_commands.delete_product_method(),
    simplify_handle(delete.handle, fn(ctx) {
      ctx.product_context.command_context.delete_ports
    }),
  )
  |> service.add_method(
    product_queries.get_product_by_barcode_method(),
    simplify_handle(get_by_barcode.handle, fn(ctx) {
      ctx.product_context.query_context.get_by_barcode_port
    }),
  )
  |> service.add_method(
    product_commands.update_product_method(),
    simplify_handle(update.handle, fn(ctx) {
      ctx.product_context.command_context.update_ports
    }),
  )
  |> service.add_method(
    stock_item_commands.create_stock_item_method(),
    simplify_handle(stock_create.handle, fn(ctx) {
      ctx.stock_item_context.command_context.create_ports
    }),
  )
  |> service.add_method(
    stock_item_queries.list_stock_items_method(),
    simplify_handle(stock_list.handle, fn(ctx) {
      ctx.stock_item_context.query_context.list_port
    }),
  )
  |> service.add_method(
    stock_item_commands.delete_stock_item_method(),
    simplify_handle(stock_delete.handle, fn(ctx) {
      ctx.stock_item_context.command_context.delete_ports
    }),
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
