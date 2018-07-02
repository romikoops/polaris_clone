# frozen_string_literal: true

class Admin::OpenPricingsController < Admin::AdminBaseController
  include ExcelTools

  def index
    @pricings = Pricing.where(customer_id: nil)

    @routes = []
    @pricings.each do |p|
      @routes.push(p.route)
    end

    response_handler(routes: @routes, pricings: @pricings)
  end

  def overwrite_main_carriage
    if params[:file] && params[:file] != "null"
      req = { "xlsx" => params[:file] }
      overwrite_mongo_pricings(req, false)
      response_handler(true)
    else
      response_handler(false)
    end
  end
end
