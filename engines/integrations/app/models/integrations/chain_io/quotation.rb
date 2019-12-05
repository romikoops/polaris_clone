# frozen_string_literal: true

module Integrations
  module ChainIo
    class Quotation < Quotations::Quotation
      has_many :tenders, inverse_of: :quotation
      has_one :cargo
    end
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  user_id              :bigint
#  tenant_id            :uuid
#  origin_nexus_id      :integer
#  destination_nexus_id :integer
#  selected_date        :datetime
#  sandbox_id           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
