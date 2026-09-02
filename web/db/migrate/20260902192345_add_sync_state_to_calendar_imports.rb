class AddSyncStateToCalendarImports < ActiveRecord::Migration[8.0]
  def change
    add_column :calendar_imports, :last_status, :string, null: false, default: "never_synced"
    add_column :calendar_imports, :last_duration_ms, :integer
    add_column :calendar_imports, :last_event_count, :integer

    add_check_constraint :calendar_imports,
      "last_status IN ('never_synced', 'success', 'failed')",
      name: "calendar_imports_valid_last_status"
    add_check_constraint :calendar_imports,
      "last_duration_ms IS NULL OR last_duration_ms >= 0",
      name: "calendar_imports_last_duration_not_negative"
    add_check_constraint :calendar_imports,
      "last_event_count IS NULL OR last_event_count >= 0",
      name: "calendar_imports_last_event_count_not_negative"
  end
end
