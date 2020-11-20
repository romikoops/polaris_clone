# frozen_string_literal: true

module Legacy
  class Content < ApplicationRecord
    extend Mobility
    has_one_attached :image

    translates :text

    def self.get_component(component_name, organization_id)
      where(organization_id: organization_id, component: component_name)
        .order(:index)
        .map(&:as_content_json)
        .group_by { |content| content["section"] }
    end

    def image_url
      Rails.application.routes.url_helpers.rails_blob_url(image) if image.attached?
    end

    def as_content_json(options = {})
      new_options = options.reverse_merge(
        methods: %i[image_url]
      )
      as_json(new_options)
    end
  end
end

# == Schema Information
#
# Table name: legacy_contents
#
#  id              :uuid             not null, primary key
#  component       :string
#  index           :integer
#  section         :string
#  text            :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_legacy_contents_on_component        (component)
#  index_legacy_contents_on_organization_id  (organization_id)
#  index_legacy_contents_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
