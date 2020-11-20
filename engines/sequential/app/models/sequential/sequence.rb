# frozen_string_literal: true

module Sequential
  class Sequence < ApplicationRecord
    validates :name, uniqueness: true
    enum name: {shipment_invoice_number: 0}

    def self.next(counter_name)
      raise ActiveRecord::Rollback unless ActiveRecord::Base.connection.open_transactions.positive?

      lock(true).find_by(name: counter_name).increment!(:value).value
    end
  end
end

# == Schema Information
#
# Table name: sequential_sequences
#
#  id         :uuid             not null, primary key
#  value      :bigint           default(0)
#  name       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
