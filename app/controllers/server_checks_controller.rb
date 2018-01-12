class ServerChecksController < ApplicationController
  def health_check
    render status: 200, json: {
      message: "Health check pinged successfully.",
    }.to_json
  end
end
