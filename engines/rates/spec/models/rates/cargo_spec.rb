# frozen_string_literal: true

require 'rails_helper'

module Rates
  RSpec.describe Cargo, type: :model do
    it 'builds a valid object' do
      expect(FactoryBot.build(:rates_cargo)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: rates_cargos
#
#  id            :uuid             not null, primary key
#  applicable_to :integer          default("self")
#  cargo_class   :integer          default("00")
#  cargo_type    :integer          default("LCL")
#  category      :integer          default(0)
#  cbm_ratio     :decimal(, )
#  code          :string
#  operator      :integer
#  order         :integer          default(0)
#  valid_at      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  section_id    :uuid
#
# Indexes
#
#  index_rates_cargos_on_cargo_class  (cargo_class)
#  index_rates_cargos_on_cargo_type   (cargo_type)
#  index_rates_cargos_on_category     (category)
#  index_rates_cargos_on_section_id   (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => rates_sections.id)
#
