import gleam/crypto
import gleam/dict
import gleam/list
import gleam/string
import simplifile

pub opaque type T {
  T(dict.Dict(BitArray, String))
}

fn hash_from_source(source: String) -> BitArray {
  crypto.hash(crypto.Sha1, <<source:utf8>>)
}

pub fn build_source_map(dir: String) -> T {
  case simplifile.get_files(dir) {
    Error(_) -> dict.new()
    Ok(files) ->
      files
      |> list.filter(fn(f) { string.ends_with(f, ".gleam") })
      |> list.filter_map(fn(path) {
        case simplifile.read(path) {
          Ok(source) -> {
            let normalized_path = string.replace(path, dir <> "/", "")
            Ok(#(hash_from_source(source), normalized_path))
          }
          Error(_) -> Error(Nil)
        }
      })
      |> dict.from_list()
  }
  |> T
}

pub fn get(map: T, source: String) -> Result(String, Nil) {
  let T(dict) = map
  hash_from_source(source)
  |> dict.get(dict, _)
}
