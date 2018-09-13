# frozen_string_literal: true
require 'bigdecimal'

class Admin::DiscountsController < Admin::AdminBaseController

  def index
    (@filterrific = initialize_filters("User")) || return
    @users = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def user_routes
    @user = User.find(params[:user_id])
    (@filterrific = initialize_filters("Route")) || return
    @routes = @filterrific.find.page(params[:page])
    @user_discounts = UserRouteDiscount.where(user: @user)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_multiple
    discount_by = params[:discount_by]
    redirect_to(:back) && return if discount_by.empty?
    discount_by = discount_by.to_d / 100
    user = User.find(params[:user_id])
    routes = Route.where(id: params[:select_route])

    routes.each do |route|
      process_user_route_discount(user, route, discount_by)
    end

    redirect_to :back
  end

  private

  def process_user_route_discount(user, route, discount_by)
    urd = UserRouteDiscount.find_by(user: user, route: route)
    if urd
      urd.update_attributes(discount_by: discount_by)
    else
      UserRouteDiscount.create(user: user, route: route, discount_by: discount_by)
    end
  end

  def initialize_filters(klass)
    initialize_filterrific(
      klass.constantize,
      params[:filterrific],
      select_options: {
        sorted_by: klass.constantize.options_for_sorted_by
      }
    )
  end
end
