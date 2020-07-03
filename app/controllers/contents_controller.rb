# frozen_string_literal: true

class ContentsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def component
    results = Legacy::Content.get_component(params[:component], current_organization.id)

    response_handler(content: results, component: params[:component])
  end
end
