import glance
import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import glinter/rule
import source_map

pub type Config(layer) {
  Config(
    allowed_imports: dict.Dict(layer, List(layer)),
    path_layer_pairs: List(#(layer, String)),
  )
}

type NextFn(a, r) =
  fn(a) -> r

type OnErrorFn(a, r) =
  fn(NextFn(a, r)) -> r

/// Useful to handle errors with use expression in handlers
pub fn on_error(value: Result(a, e), on_error: fn(e) -> r) -> OnErrorFn(a, r) {
  fn(next: NextFn(a, r)) -> r {
    case value {
      Ok(ok) -> next(ok)
      Error(err) -> on_error(err)
    }
  }
}

/// Useful to handle errors with use expression in handlers
/// Returns a fixed value no matter the error
pub fn on_error_value(
  value value: Result(a, e),
  on_error on_error_response: r,
) -> OnErrorFn(a, r) {
  on_error(value, fn(_) { on_error_response })
}

fn find_layers_for_path(
  path: String,
  path_layer_pairs: List(#(layer, String)),
) -> Set(layer) {
  list.filter_map(path_layer_pairs, fn(pair) {
    let #(layer, prefix) = pair
    use <- bool.guard(path == prefix, Ok(layer))
    use <- bool.guard(!string.starts_with(path, prefix <> "/"), Error(Nil))
    Ok(layer)
  })
  |> set.from_list
}

fn import_visitor(
  import_def: glance.Definition(glance.Import),
  config: Config(layer),
  allowed_layers: Set(layer),
) -> List(rule.RuleError) {
  let build_error = fn() {
    [
      rule.error(
        "Import from forbidden layer",
        details: "",
        location: import_def.definition.location,
      ),
    ]
  }

  let layers =
    find_layers_for_path(import_def.definition.module, config.path_layer_pairs)
  // If the import doesn't belong to any configured layer, it can not be allowed
  use <- bool.guard(set.size(layers) == 0, build_error())

  let forbidden_layers = set.difference(layers, allowed_layers)
  case set.size(forbidden_layers) {
    0 -> []
    _ -> build_error()
  }
}

pub fn rule(config: Config(layer), source_map: source_map.T) -> rule.Rule {
  rule.module_rule_from_fn("depends_only_on", rule.Error, fn(module, source) {
    use module_path <-
      source_map.get(source_map, source)
      |> on_error_value([
        rule.error(
          "File not found in source map",
          details: "",
          location: glance.Span(0, 1),
        ),
      ])
    let layers = find_layers_for_path(module_path, config.path_layer_pairs)

    // If the file doesn't belong to any configured layer, we don't want to report errors for it
    use <- bool.guard(set.size(layers) == 0, [])

    let allowed_layers =
      set.to_list(layers)
      |> list.flat_map(fn(layer) {
        // Get allowed imports for these layers
        result.unwrap(dict.get(config.allowed_imports, layer), [])
      })
      |> set.from_list()
    // Now we can visit the imports with the file_path as context
    module.imports
    |> list.flat_map(import_visitor(_, config, allowed_layers))
  })
}
