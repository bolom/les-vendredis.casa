require "test_helper"

class AddTechnicalAccessToUsersMigrationTest < ActiveSupport::TestCase
  # The migration already ran when the test database was prepared, so the
  # down path runs first here, then the up path must re-create the column
  # with default: false and open (true) every account that existed before
  # the flag. New accounts still start closed.
  test "backfills existing accounts to true while new accounts stay closed" do
    context = ActiveRecord::Base.connection_pool.migration_context
    context.run(:down, 20260908140000)
    User.reset_column_information

    assert_not User.column_names.include?("technical_access")

    context.run(:up, 20260908140000)
    User.reset_column_information

    column = User.columns_hash.fetch("technical_access")
    assert_equal :boolean, column.type
    assert_equal true, users(:one).reload.technical_access
    assert_equal true, users(:two).reload.technical_access

    # New accounts start closed: the flag's column default is false.
    newly_created = User.create!(email_address: "nouveau@example.com", password: "motdepasse1")
    assert_equal false, newly_created.technical_access
  end
end
