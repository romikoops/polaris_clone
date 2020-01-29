# frozen_string_literal: true

FactoryBot.define do
  factory :optin_status do
    tenant { false }
    itsmycargo { false }
    cookies { false }
  end
end

# == Schema Information
#
# Table name: optin_statuses
#
#  id         :bigint           not null, primary key
#  cookies    :boolean
#  itsmycargo :boolean
#  tenant     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_optin_statuses_on_sandbox_id  (sandbox_id)
#
