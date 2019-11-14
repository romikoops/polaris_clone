# frozen_string_literal: true

module Shipments
  class Document < ApplicationRecord
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    enum doc_type: { packing_sheet: 0,
                     commercial_invoice: 1,
                     miscellaneous: 2,
                     customs_declaration: 3,
                     export_customs_paper: 4,
                     customs_value_declaration: 5 }

    belongs_to :attachable, polymorphic: true
    belongs_to :user, class_name: 'Tenants::User'

    has_one_attached :file

    validates :attachable, presence: true
  end
end

# == Schema Information
#
# Table name: shipments_documents
#
#  id              :uuid             not null, primary key
#  attachable_type :string           not null
#  attachable_id   :uuid             not null
#  sandbox_id      :uuid
#  doc_type        :integer
#  file_name       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
