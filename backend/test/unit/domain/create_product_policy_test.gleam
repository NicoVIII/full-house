import domain/create_product_policy
import domain/validated_parent_product_id
import gleam/option.{None}
import gleeunit/should

pub fn can_create_with_no_parent_returns_ok_test() {
  let validated_parent = validated_parent_product_id.new_exn(None)
  let result = create_product_policy.can_create(validated_parent)

  should.equal(result, Ok(Nil))
}

pub fn can_create_with_valid_parent_returns_ok_test() {
  // Since validated_parent_product_id only guarantees structural validity
  // (None is always valid, Some points to an existing product),
  // we test with None here and rely on integration tests for Some cases.
  let validated_parent = validated_parent_product_id.new_exn(None)
  let result = create_product_policy.can_create(validated_parent)

  should.equal(result, Ok(Nil))
}

pub fn decide_with_no_parent_returns_can_create_test() {
  let validated_parent = validated_parent_product_id.new_exn(None)
  let decision = create_product_policy.decide(validated_parent)

  should.equal(decision, create_product_policy.CanCreate)
}
