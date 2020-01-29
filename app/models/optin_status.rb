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
