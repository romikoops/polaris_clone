# frozen_string_literal: true

module Legacy
  class ExchangeRate < ApplicationRecord
    self.table_name = "exchange_rates"

    def self.current
      find_by_sql(
        arel_table.project(arel_table[Arel.star])
                  .distinct_on([arel_table[:from], arel_table[:to]])
                  .order(arel_table[:from], arel_table[:to], arel_table[:created_at].desc)
      )
    end
  end
end
