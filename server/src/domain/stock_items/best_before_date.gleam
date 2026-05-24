import common/best_before_date_parser

pub opaque type T {
  BestBeforeDate(value: String)
}

pub type ValidationError {
  Empty
  InvalidFormat
  InvalidDate
}

pub fn new(raw: String) -> Result(T, ValidationError) {
  case raw {
    "" -> Error(Empty)
    _ ->
      case best_before_date_parser.parse_yyyy_mm_dd(raw) {
        Ok(parsed) -> Ok(BestBeforeDate(parsed))
        Error(error) ->
          case error {
            best_before_date_parser.InvalidFormat -> Error(InvalidFormat)
            best_before_date_parser.InvalidDate -> Error(InvalidDate)
          }
      }
  }
}

pub fn to_value(date: T) -> String {
  date.value
}
