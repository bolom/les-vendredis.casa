class AddTechnicalAccessToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :technical_access, :boolean, default: false, null: false

    # Backfill existing admin accounts: they were created before the flag
    # existed and the Users screen itself sits behind it, so defaulting them
    # to false would lock every operator out of the technical zone with no
    # way back in. New accounts still start closed (default: false).
    execute "UPDATE users SET technical_access = true"
  end

  def down
    remove_column :users, :technical_access
  end
end
