class Content < ApplicationRecord
  extend Mobility
  has_one_attached :image
  translates :text
  def self.get_component(component_name, tenant_id)
    where(tenant_id: tenant_id, component: component_name)
      .map(&:as_content_json)
      .group_by {|x| x['section'] }
      .each {|section, values| values.sort_by! {|x| x['index']}}
  end

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image) if image.attached?
  end

  def as_content_json(options={})
    new_options = options.reverse_merge(
      methods: %i(image_url)
    )
    as_json(new_options)
  end


end
