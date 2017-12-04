class Admin::DiscountsController < ApplicationController
  before_action :require_login_and_role_is_admin

  

  def index
    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      select_options: {
        sorted_by: User.options_for_sorted_by,
      }
    ) or return
    @users = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def user_routes
    @user = User.find(params[:user_id])

    @filterrific = initialize_filterrific(
      Route,
      params[:filterrific],
      select_options: {
        sorted_by: Route.options_for_sorted_by,
      }
    ) or return
    @routes = @filterrific.find.page(params[:page])

    @user_discounts = UserRouteDiscount.where(user: @user)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_multiple
    discount_by = params[:discount_by]
    redirect_to :back and return if discount_by.empty?
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

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
