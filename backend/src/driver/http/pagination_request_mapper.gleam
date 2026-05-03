import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/paging
import gleam/int
import gleam/list
import gleam/result

pub type ValidationError(a) {
  ParseError
  ValidationError(a)
}

type LimitError =
  ValidationError(page_limit.Error)

fn parse_limit(raw: String) -> Result(page_limit.T, LimitError) {
  use n <- result.try(case int.parse(raw) {
    Ok(n) -> Ok(n)
    Error(Nil) -> Error(ParseError)
  })

  page_limit.new(n)
  |> result.map_error(ValidationError)
}

fn parse_limit_param(
  query: List(#(String, String)),
) -> Result(page_limit.T, LimitError) {
  case list.key_find(query, "limit") {
    Ok(raw) -> parse_limit(raw)
    Error(Nil) -> Ok(page_limit.default())
  }
}

type OffsetError =
  ValidationError(page_offset.Error)

fn parse_offset(raw: String) -> Result(page_offset.T, OffsetError) {
  use n <- result.try(case int.parse(raw) {
    Ok(n) -> Ok(n)
    Error(Nil) -> Error(ParseError)
  })

  page_offset.new(n)
  |> result.map_error(ValidationError)
}

fn parse_offset_param(
  query: List(#(String, String)),
) -> Result(page_offset.T, OffsetError) {
  case list.key_find(query, "offset") {
    Ok(raw) -> parse_offset(raw)
    Error(Nil) -> Ok(page_offset.default())
  }
}

pub type Error {
  LimitError(LimitError)
  OffsetError(OffsetError)
}

pub fn map_paging_params(
  query: List(#(String, String)),
) -> Result(paging.Params, Error) {
  use limit <- result.try(
    parse_limit_param(query) |> result.map_error(LimitError),
  )
  use offset <- result.try(
    parse_offset_param(query) |> result.map_error(OffsetError),
  )

  Ok(paging.Params(limit, offset))
}

pub fn error_to_string(error: Error) -> String {
  case error {
    LimitError(ParseError) -> "Invalid limit parameter"
    LimitError(ValidationError(page_limit.GreaterThanZero)) ->
      "Invalid limit parameter: must be greater than 0"
    LimitError(ValidationError(page_limit.LessThanOrEqualToMax)) ->
      "Invalid limit parameter: must be between 1 and 100"
    OffsetError(ParseError) -> "Invalid offset parameter"
    OffsetError(ValidationError(page_offset.GreaterThanOrEqualToZero)) ->
      "Invalid offset parameter: must be greater than or equal to 0"
  }
}
