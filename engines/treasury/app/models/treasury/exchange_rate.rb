# frozen_string_literal: true

module Treasury
  class ExchangeRate < ApplicationRecord
    def self.current
      select("DISTINCT ON (\"from\" , \"to\") *")
        .order(:from, :to, created_at: :desc)
    end

    def self.for_date(date:)
      select("DISTINCT ON (\"from\" , \"to\") *")
        .where("created_at < ?", date.utc)
        .order(:from, :to, created_at: :desc)
    end
  end
end

# == Schema Information
#
# Table name: treasury_exchange_rates
#
#  id         :uuid             not null, primary key
#  from       :string
#  rate       :decimal(, )
#  to         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_treasury_exchange_rates_on_created_at  (created_at)
#  index_treasury_exchange_rates_on_from        (from)
#  index_treasury_exchange_rates_on_to          (to)
#
