class Content < ApplicationRecord
  extend Mobility
  has_one_attached :image
  translates :text
  def self.get_component(component_name, tenant_id)
    where(tenant_id: tenant_id, component: component_name)
      .group_by {|x| x.section }
      .each {|section, values| values.sort_by! {|x| x.index}}
  end
end
