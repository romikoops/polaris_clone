# frozen_string_literal: true
module Routing
  class Carrier < ApplicationRecord
    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :code, presence: true, uniqueness: { case_sensitive: false }
    has_one_attached :logo
  end
end

# == Schema Information
#
# Table name: routing_carriers
#
#  id               :uuid             not null, primary key
#  abbreviated_name :string
#  code             :string
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  routing_carriers_index  (name,code,abbreviated_name) UNIQUE
#
