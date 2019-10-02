# frozen_string_literal: true

module Legacy
  class Quotation < ApplicationRecord
    self.table_name = 'quotations'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  target_email         :string
#  user_id              :integer
#  name                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  original_shipment_id :integer
#  sandbox_id           :uuid
#
