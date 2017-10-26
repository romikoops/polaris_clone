# Prevent normal registration, redirect to "Please email us page"

class UsersDevise::RegistrationsController < Devise::RegistrationsController
  def new
    # render "devise/registrations/beta_phase/index"
    super
  end

  def create
    # render "devise/registrations/beta_phase/index"
    super
  end
end