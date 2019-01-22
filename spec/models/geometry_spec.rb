# frozen_string_literal: true

require 'rails_helper'

describe Geometry, type: :model do
  context 'class methods' do
    describe '.cascading_find_by_names' do
      let(:geometry_1) { create(:geometry) }
      let(:geometry_2) { create(:geometry, name_3: 'Anotherplace3') }
      let(:geometry_3) { create(:geometry, name_3: 'Yetanotherplace3', name_4: 'Yetanotherplace4') }

      let(:name_broad)     { 'GOTHENBURG' }
      let(:name_narrower)  { 'Anotherplace3' }
      let(:name_narrowest) { 'Yetanotherplace4' }

      # context 'basic tests' do
      #   it '...' do
      #   end
      # end

      context 'one name passed' do
        it 'finds the correct geometry if the city name is passed' do
          geometry_1
          found_geometry = described_class.cascading_find_by_names(name_broad)

          expect(found_geometry).to eq(geometry_1)
        end

        it 'finds the correct geometry if the locality is passed' do
          geometry_2
          geometry_3
          geometry_1
          found_geometry = described_class.cascading_find_by_names(name_narrower)

          expect(found_geometry).to eq(geometry_2)
        end

        it 'finds the correct geometry if the sublocality is passed' do
          geometry_3
          geometry_2
          geometry_1
          found_geometry = described_class.cascading_find_by_names(name_narrowest)

          expect(found_geometry).to eq(geometry_3)
        end
      end

      context 'two names passed' do
        it 'finds the correct geometry if the city name and locality are passed' do
          geometry_2
          geometry_1
          geometry_3
          found_geometry = described_class.cascading_find_by_names(name_broad, name_narrower)

          expect(found_geometry).to eq(geometry_2)
        end

        it 'finds the correct geometry if the city name and sublocality are passed' do
          geometry_3
          geometry_1
          geometry_2
          found_geometry = described_class.cascading_find_by_names(name_broad, name_narrowest)

          expect(found_geometry).to eq(geometry_3)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: geometries
#
#  id         :bigint(8)        not null, primary key
#  name_1     :string
#  name_2     :string
#  name_3     :string
#  name_4     :string
#  data       :geometry({:srid= geometry, 0
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
