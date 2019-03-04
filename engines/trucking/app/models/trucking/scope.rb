# frozen_string_literal: true

module Trucking
  class Scope < ApplicationRecord
    has_many :rates, class_name: 'Trucking::Rate'
    belongs_to :courier, class_name: 'Trucking::Courier'
  end
end

# == Schema Information
#
# Table name: trucking_scopes
#
#  id          :uuid             not null, primary key
#  load_type   :string
#  cargo_class :string
#  carriage    :string
#  courier_id  :uuid
#  truck_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
