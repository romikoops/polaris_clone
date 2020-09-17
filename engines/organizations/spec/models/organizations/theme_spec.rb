require "rails_helper"

module Organizations
  RSpec.describe Theme, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end

# == Schema Information
#
# Table name: organizations_themes
#
#  id                     :uuid             not null, primary key
#  bright_primary_color   :string
#  bright_secondary_color :string
#  emails                 :jsonb
#  primary_color          :string
#  secondary_color        :string
#  welcome_text           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organization_id        :uuid
#
# Indexes
#
#  index_organizations_themes_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
