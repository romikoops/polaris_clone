# frozen_string_literal: true

module Legacy
  class TransportCategory < ApplicationRecord
    self.table_name = 'transport_categories'
    belongs_to :vehicle, class_name: 'Legacy::Vehicle'

    validates :cargo_class, presence: true
  end
end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint           not null, primary key
#  vehicle_id        :integer
#  mode_of_transport :string
#  name              :string
#  cargo_class       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  load_type         :string
#  sandbox_id        :uuid
#
