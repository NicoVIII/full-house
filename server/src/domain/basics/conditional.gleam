import gleam/bool

/// Prepend an element to a list conditionally.
/// 
/// If the condition is True, prepends the element to the list.
/// If the condition is False, returns the list unchanged.
/// 
/// Useful for building up lists of errors or other items based on validation conditions.
pub fn prepend_if(
  to list: List(a),
  when condition: Bool,
  el element: a,
) -> List(a) {
  use <- bool.guard(!condition, list)

  [element, ..list]
}
