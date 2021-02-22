# frozen_string_literal: true
module Quotations
  class QuotationsMigrateCreatorToPolymorphicWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform
      total Quotations::Quotation.count

      Quotations::Quotation.find_each.with_index do |quotation, index|
        at(index + 1)

        next if quotation[:user_id].blank?

        ActiveRecord::Base.connection.execute(<<-SQL)
          UPDATE quotations_quotations
          SET creator_type = CASE
            WHEN u.type = 'Organizations::User' THEN 'Users::Client'
            ELSE u.type
          END
          FROM quotations_quotations q
            LEFT JOIN users_users u ON q.creator_id = u.id
          WHERE
            q.creator_type IS NULL
            AND u.id = '#{quotation[:user_id]}'
            AND q.id = '#{quotation[:id]}'
        SQL
      end
    end
  end
end
