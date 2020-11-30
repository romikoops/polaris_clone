# frozen_string_literal: true

require "rails_helper"

module CmsData
  RSpec.describe Widget, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:cms_data_widget)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: cms_data_widgets
#
#  id              :uuid             not null, primary key
#  data            :string           not null
#  name            :string           not null
#  order           :integer          not nulll
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_organizations_widgets_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
