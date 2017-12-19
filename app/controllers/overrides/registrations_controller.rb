module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    wrap_parameters false
    # def render_create_success
    #   render json: {data: @resource.errors}
    # end
    def create
      byebug
      u = User.new(:name => "Guest", :email => "guest_#{Time.now.to_i}#{rand(100)}@example.com")
      u.save!(:validate => false)
    end
    def render_create_error_not_confirmed
      byebug
    end
    def render_create_error_bad_credentials
      byebug
    end
  end
end