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

    def self.for_date(date:)
      find_by_sql(
        arel_table.project(arel_table[Arel.star])
                  .where(arel_table[:created_at].lt(date))
                  .distinct_on([arel_table[:from], arel_table[:to]])
                  .order(arel_table[:from], arel_table[:to], arel_table[:created_at].desc)
      )
    end
  end
end

# == Schema Information
#
# Table name: exchange_rates
#
#  id         :bigint           not null, primary key
#  from       :string
#  rate       :decimal(, )
#  to         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_exchange_rates_on_created_at  (created_at)
#  index_exchange_rates_on_from        (from)
#  index_exchange_rates_on_to          (to)
#
