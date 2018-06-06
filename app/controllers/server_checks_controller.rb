# frozen_string_literal: true

class ServerChecksController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def health_check
    response_handler(message: 'Health check pinged successfully.')
  end
end
