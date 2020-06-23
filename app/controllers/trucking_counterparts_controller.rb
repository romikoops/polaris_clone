# frozen_string_literal: true

class TruckingCounterpartsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    response_handler(counterpart_countries)
  end

  private

  def counterpart_countries
    countries = Api::Routing::Trucking::CountriesService.new(
      tenant: ::Tenants::Tenant.find_by(legacy_id: current_tenant&.id),
      load_type: query_params[:load_type],
      target: target,
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
