class AddNightlyPriceToStayRules < ActiveRecord::Migration[8.0]
  def change
    add_column :stay_rules, :nightly_price_eur, :decimal, precision: 10, scale: 2
    add_check_constraint :stay_rules, "nightly_price_eur IS NULL OR nightly_price_eur > 0", name: "stay_rules_positive_price"
  end
end
