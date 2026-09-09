# frozen_string_literal: true

class CreateAgentTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_tokens do |t|
      t.string :name, null: false
      t.string :token_digest, null: false
      t.string :token_prefix, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :permissions, default: [], null: false
      t.datetime :last_used_at
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [ "token_digest" ], name: "index_agent_tokens_on_token_digest", unique: true
      t.index [ "token_prefix" ], name: "index_agent_tokens_on_token_prefix"
    end
  end
end
