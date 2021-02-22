# frozen_string_literal: true
module Journey
  class Error < ApplicationRecord
    belongs_to :result_set
    belongs_to :cargo_unit, optional: true
  end
end

# == Schema Information
#
# Table name: journey_errors
#
#  id                :uuid             not null, primary key
#  carrier           :string
#  code              :integer
#  limit             :string
#  mode_of_transport :string
#  property          :string
#  service           :string
#  value             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cargo_unit_id     :uuid
#  result_set_id     :uuid
#
# Indexes
#
#  index_journey_errors_on_cargo_unit_id  (cargo_unit_id)
#  index_journey_errors_on_result_set_id  (result_set_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_unit_id => journey_cargo_units.id) ON DELETE => cascade
#  fk_rails_...  (result_set_id => journey_result_sets.id) ON DELETE => cascade
#
