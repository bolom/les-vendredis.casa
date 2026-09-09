# frozen_string_literal: true

class CreateAgentActionLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_action_logs do |t|
      t.references :agent_token, null: false, foreign_key: true
      t.string :action, null: false
      t.string :target_type
      t.bigint :target_id
      t.string :result, null: false, default: "ok"
      t.jsonb :details, default: {}, null: false
      t.string :request_key
      t.datetime :created_at, null: false

      t.index [ :agent_token_id, :created_at ], name: "index_agent_action_logs_on_agent_token_id_and_created_at"
      t.index [ :target_type, :target_id ], name: "index_agent_action_logs_on_target"
    end
  end
end
