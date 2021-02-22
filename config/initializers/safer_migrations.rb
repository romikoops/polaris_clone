# frozen_string_literal: true
if Rails.env.development?
  ActiveRecord::SaferMigrations.default_lock_timeout = 500
  ActiveRecord::SaferMigrations.default_statement_timeout = 1000
else
  ActiveRecord::SaferMigrations.default_lock_timeout = 1000
  ActiveRecord::SaferMigrations.default_statement_timeout = 2000
end
