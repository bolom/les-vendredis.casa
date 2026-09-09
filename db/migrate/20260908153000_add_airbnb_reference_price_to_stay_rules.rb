# frozen_string_literal: true

# Bolo's rule: a direct booking must always be cheaper than the same dates on
# Airbnb. The Airbnb nightly price is the reference; the direct price is what
# we charge. Storing both makes the comparison auditable and lets the admin
# refuse a direct price that is not actually cheaper.
class AddAirbnbReferencePriceToStayRules < ActiveRecord::Migration[8.0]
  def change
    add_column :stay_rules, :airbnb_nightly_price_eur, :decimal, precision: 10, scale: 2

    add_check_constraint :stay_rules,
      "airbnb_nightly_price_eur IS NULL OR airbnb_nightly_price_eur > 0",
      name: "stay_rules_positive_airbnb_price"

    add_check_constraint :stay_rules,
      "airbnb_nightly_price_eur IS NULL OR nightly_price_eur IS NULL OR nightly_price_eur < airbnb_nightly_price_eur",
      name: "stay_rules_direct_cheaper_than_airbnb"
  end
end
