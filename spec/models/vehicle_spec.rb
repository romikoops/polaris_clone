# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  context 'validations' do
    describe '#name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:mode_of_transport).with_message(/taken for mode of transport/) }
    end
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
