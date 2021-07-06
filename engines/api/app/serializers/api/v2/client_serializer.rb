# frozen_string_literal: true

module Api
  module V2
    class ClientSerializer < Api::ApplicationSerializer
      attributes %i[email organization_id first_name last_name phone company_name]
    end
  end
end
