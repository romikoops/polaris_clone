# frozen_string_literal: true

module Legacy
  class Quotation < ApplicationRecord
    self.table_name = 'quotations'
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint(8)        not null, primary key
#  target_email         :string
#  user_id              :integer
#  name                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  original_shipment_id :integer
#
