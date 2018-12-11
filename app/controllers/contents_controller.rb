class ContentsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!
  def component
    results = Content.get_component(params[:component], current_tenant.id)
    response_handler({content: results , component: params[:component] })
  end
end
