# frozen_string_literal: true

class Content < ApplicationRecord
  extend Mobility
  has_one_attached :image
  translates :text
  def self.get_component(component_name, tenant_id)
    where(tenant_id: tenant_id, component: component_name)
      .map(&:as_content_json)
      .group_by { |x| x['section'] }
      .each { |_section, values| values.sort_by! { |x| x['index'] } }
  end

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image) if image.attached?
  end

  def as_content_json(options = {})
    new_options = options.reverse_merge(
      methods: %i(image_url)
    )
    as_json(new_options)
  end
end

# == Schema Information
#
# Table name: contents
#
#  id         :bigint(8)        not null, primary key
#  text       :jsonb
#  component  :string
#  section    :string
#  index      :integer
#  tenant_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
