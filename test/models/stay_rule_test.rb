require "test_helper"

class StayRuleTest < ActiveSupport::TestCase
  test "direct price must be lower than the airbnb reference price" do
    rule = StayRule.new(nightly_price_eur: 74, airbnb_nightly_price_eur: 71, maximum_adults: 2)

    assert_not rule.valid?
    assert_includes rule.errors[:nightly_price_eur], "must be lower than the Airbnb price for the same dates"
  end

  test "equal to the airbnb price is refused too" do
    rule = StayRule.new(nightly_price_eur: 71, airbnb_nightly_price_eur: 71, maximum_adults: 2)

    assert_not rule.valid?
  end

  test "a strictly lower direct price is accepted" do
    rule = StayRule.new(nightly_price_eur: 68, airbnb_nightly_price_eur: 71, maximum_adults: 2)

    assert rule.valid?
  end

  test "the database refuses a direct price that is not cheaper" do
    rule = StayRule.new(nightly_price_eur: 80, airbnb_nightly_price_eur: 71, maximum_adults: 2)

    assert_raises(ActiveRecord::StatementInvalid) { rule.save(validate: false) }
  end

  test "price_for multiplies the nightly price by the nights" do
    rule = StayRule.new(nightly_price_eur: 68, airbnb_nightly_price_eur: 71, maximum_adults: 2)

    assert_equal BigDecimal("136"), rule.price_for(2)
  end

  test "price_for is nil when no price is configured" do
    assert_nil StayRule.new(maximum_adults: 2).price_for(2)
  end
end
