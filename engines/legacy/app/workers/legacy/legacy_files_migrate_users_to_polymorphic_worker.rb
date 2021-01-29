module Legacy
  class LegacyFilesMigrateUsersToPolymorphicWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform
      total Legacy::File.count

      Legacy::File.find_each.with_index do |file, index|
        at(index + 1)

        next if file[:user_id].blank?

        ActiveRecord::Base.connection.execute(<<-SQL)
          UPDATE legacy_files
            SET user_type = CASE
              WHEN u.type = 'Organizations::User' THEN 'Users::Client'
              ELSE u.type
              END
          FROM legacy_files f
            LEFT JOIN users_users u ON f.user_id = u.id
          WHERE
            f.user_type IS NULL
            AND u.id = '#{file[:user_id]}'
            AND f.id = '#{file[:id]}'
        SQL
      end
    end
  end
end
