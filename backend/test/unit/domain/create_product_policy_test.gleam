import domain/basics/uuid
import domain/products/creation/policy as create_product_policy
import domain/products/creation/validated_parent_id as validated_parent_product_id
import domain/products/product
import gleeunit/should

pub fn can_create_with_valid_parent_returns_ok_test() {
  // Create a validated parent with a sample product ID
  let sample_id = product.ProductId(uuid.generate_v7())
  let validated_parent = validated_parent_product_id.new(sample_id)
  let result = create_product_policy.can_create(validated_parent)

  should.equal(result, Ok(Nil))
}

pub fn decide_with_valid_parent_returns_can_create_test() {
  // Create a validated parent with a sample product ID
  let sample_id = product.ProductId(uuid.generate_v7())
  let validated_parent = validated_parent_product_id.new(sample_id)
  let decision = create_product_policy.decide(validated_parent)

  should.equal(decision, create_product_policy.CanCreate)
}
