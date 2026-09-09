# frozen_string_literal: true

class CreateAgentIdempotencyKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_idempotency_keys do |t|
      t.references :agent_token, null: false, foreign_key: true
      t.string :key, null: false
      t.string :action, null: false
      t.string :result_status, null: false
      t.jsonb :result_body, null: false
      t.datetime :created_at, null: false

      t.index [ :agent_token_id, :key ], name: "index_agent_idempotency_keys_on_agent_token_id_and_key", unique: true
    end
  end
end
