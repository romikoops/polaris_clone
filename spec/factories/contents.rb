FactoryBot.define do
  factory :content do
    
  end
end

# == Schema Information
#
# Table name: contents
#
#  id         :bigint(8)        not null, primary key
#  text       :jsonb
#  component  :string
#  section    :string
#  index      :integer
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
