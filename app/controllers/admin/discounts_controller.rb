# frozen_string_literal: true

class Admin::DiscountsController < Admin::AdminBaseController

  def index
    (@filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      select_options: {
        sorted_by: User.options_for_sorted_by
      }
    )) || return
    @users = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def user_routes
    @user = User.find(params[:user_id])

    (@filterrific = initialize_filterrific(
      Route,
      params[:filterrific],
      select_options: {
        sorted_by: Route.options_for_sorted_by
      }
    )) || return
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
      urd = UserRouteDiscount.find_by(user: user, route: route)
      if urd
        urd.update_attributes(discount_by: discount_by)
      else
        UserRouteDiscount.create(user: user, route: route, discount_by: discount_by)
      end
    end

    redirect_to :back
  end
end
