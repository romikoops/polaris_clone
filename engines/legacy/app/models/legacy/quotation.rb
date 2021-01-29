# frozen_string_literal: true

module Legacy
  class Quotation < ApplicationRecord
    self.table_name = "quotations"

    has_many :shipments, class_name: "Legacy::Shipment"
    has_many :files, class_name: "Legacy::File", dependent: :destroy
    belongs_to :user, class_name: "Users::Client", optional: true
    belongs_to :original_shipment, class_name: "Legacy::Shipment"

    enum billing: {external: 0, internal: 1, test: 2}
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  billing              :integer          default("external")
#  name                 :string
#  target_email         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  distinct_id          :uuid
#  legacy_user_id       :integer
#  original_shipment_id :integer
#  sandbox_id           :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_on_sandbox_id  (sandbox_id)
#  index_quotations_on_user_id     (user_id)
#
