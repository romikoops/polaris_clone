# frozen_string_literal: true

class OptinStatus < ApplicationRecord
  has_many :users
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  def self.create_all!
    [true, false].repeated_permutation(3).to_a.each do |values|
      attributes = OptinStatus.given_attribute_names.zip(values).to_h
      OptinStatus.find_or_create_by!(attributes)
    end
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
#  sandbox_id :uuid
#
