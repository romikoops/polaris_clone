# frozen_string_literal: true

class Quotation < ApplicationRecord
  has_many :shipments
  has_many :documents
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  belongs_to :user
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  target_email         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  original_shipment_id :integer
#  sandbox_id           :uuid
#  user_id              :integer
#
# Indexes
#
#  index_quotations_on_sandbox_id  (sandbox_id)
#
