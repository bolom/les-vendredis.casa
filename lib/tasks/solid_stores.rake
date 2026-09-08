namespace :db do
  desc "Create Solid Queue/Cache/Cable stores and load their schema if missing (idempotent, refs #33)"
  task solid_stores: :environment do
    # For each Solid role: create its database if missing, then load the
    # role schema (db/<role>_schema.rb) only when its marker table is
    # absent. db:prepare alone never loads these schemas when the roles
    # share one physical Postgres database with primary (refs #33).
    stores = {
      "queue" => [ "solid_queue_jobs", "db/queue_schema.rb" ],
      "cache" => [ "solid_cache_entries", "db/cache_schema.rb" ],
      "cable" => [ "solid_cable_messages", "db/cable_schema.rb" ]
    }
    lock_key = 625_114_033 # pg_advisory_lock key, arbitrary but fixed

    stores.each do |role, (marker_table, schema_path)|
      config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: role)
      raise "Missing #{Rails.env}/#{role} database config" unless config

      begin
        ActiveRecord::Tasks::DatabaseTasks.create(config)
      rescue ActiveRecord::DatabaseAlreadyExists
        nil # shared physical database already exists
      end

      ActiveRecord::Tasks::DatabaseTasks.with_temporary_connection(config) do
        conn = ActiveRecord::Base.connection
        next if conn.table_exists?(marker_table)

        conn.execute("SELECT pg_advisory_lock(#{lock_key})")
        begin
          # Re-check under lock: web and worker may bootstrap concurrently.
          next if conn.table_exists?(marker_table)

          ActiveRecord::Schema.verbose = false
          load Rails.root.join(schema_path).to_s
        ensure
          conn.execute("SELECT pg_advisory_unlock(#{lock_key})")
        end
      end

      puts "solid_stores: #{role} ready"
    end
  end
end
