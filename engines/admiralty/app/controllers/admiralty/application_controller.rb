# frozen_string_literal: true

module Admiralty
  class ApplicationController < AdmiraltyAuth::AuthorizedController
    helper AdmiraltyAssets::Engine.helpers
    layout "admiralty_assets/application"
  end
end
