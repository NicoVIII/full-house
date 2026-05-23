import tempo
import tempo/date
import tempo/error as tempo_error

pub type Error {
  InvalidFormat
  InvalidDate
}

pub fn parse_yyyy_mm_dd(raw: String) -> Result(String, Error) {
  case date.parse(raw, tempo.CustomDate("YYYY-MM-DD")) {
    Ok(parsed) -> Ok(date.to_string(parsed))
    Error(error) ->
      case error {
        tempo_error.DateInvalidFormat(_) -> Error(InvalidFormat)
        tempo_error.DateOutOfBounds(_, _) -> Error(InvalidDate)
      }
  }
}
