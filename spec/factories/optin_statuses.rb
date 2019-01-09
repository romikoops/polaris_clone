FactoryBot.define do
  factory :optin_status do
    tenant false
    itsmycargo false
    cookies false
  end
end

# == Schema Information
#
# Table name: optin_statuses
#
#  id         :bigint(8)        not null, primary key
#  cookies    :boolean
#  tenant     :boolean
#  itsmycargo :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
