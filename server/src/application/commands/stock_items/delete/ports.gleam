import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/best_before_date

pub type DeleteOutcome {
  Deleted
  NotFound
}

pub type Delete =
  fn(product_id.T, best_before_date.T) ->
    Result(DeleteOutcome, infrastructure_error.T)
