# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe Quotations::Quotation, type: :model do
    subject { FactoryBot.build :quotations_quotation }

    context 'Associations' do
      %i(tenant user origin_nexus destination_nexus sandbox).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'Validity' do
      it { is_expected.to be_valid }
    end
    
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  destination_nexus_id :integer
#  origin_nexus_id      :integer
#  sandbox_id           :bigint
#  tenant_id            :uuid
#  user_id              :bigint
#
# Indexes
#
#  index_quotations_quotations_on_destination_nexus_id  (destination_nexus_id)
#  index_quotations_quotations_on_origin_nexus_id       (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id            (sandbox_id)
#  index_quotations_quotations_on_tenant_id             (tenant_id)
#  index_quotations_quotations_on_user_id               (user_id)
#
