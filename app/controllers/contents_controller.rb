class ContentsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def component
    results = Content.where(tenant_id: current_tenant.id, component: params[:component])
      .group_by {|x| x.section }
      .each {|section, values| values.sort_by {|x| x.index}}
    response_handler({content: results , component: params[:component] })
  end
end
