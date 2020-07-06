# frozen_string_literal: true

class TruckingCounterpartsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    response_handler(counterpart_countries)
  end

  private

  def counterpart_countries
    countries = Api::Routing::Trucking::CountriesService.new(
      organization: current_organization,
      load_type: query_params[:load_type],
      target: target,
      user: organization_user,
      coordinates: query_params.slice(:lat, :lng),
      nexus_id: query_params[:nexus_id]
    ).perform

    countries.pluck(:code)
  end

  def target
    query_params[:target].to_sym
  end

  def query_params
    params.permit(:lat, :lng, :nexus_id, :load_type, :target)
  end
end
