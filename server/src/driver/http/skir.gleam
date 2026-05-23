import driver/http/wire_format
import gleam/bytes_tree
import skir_client
import skir_client/serializer
import wisp

pub fn encode(
  response: wisp.Response,
  value: a,
  serializer: skir_client.Serializer(a),
  format: wire_format.T,
) -> wisp.Response {
  response
  |> wisp.set_header("content-type", case format {
    wire_format.ReadableJson -> wire_format.readable_json_mime
    wire_format.DenseJson -> wire_format.dense_json_mime
    wire_format.Binary -> wire_format.binary_mime
  })
  |> wisp.set_body(case format {
    wire_format.ReadableJson ->
      wisp.Text(serializer.to_readable_json_code(serializer, value))
    wire_format.DenseJson ->
      wisp.Text(serializer.to_dense_json_code(serializer, value))
    wire_format.Binary ->
      wisp.Bytes(
        serializer.to_bytes(serializer, value)
        |> bytes_tree.from_bit_array,
      )
  })
}
