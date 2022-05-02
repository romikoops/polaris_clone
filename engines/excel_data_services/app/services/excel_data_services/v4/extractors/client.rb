# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Client < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Users::Client.select("id AS user_id, email, organization_id")
        end

        def join_arguments
          { "email" => "email", "organization_id" => "organization_id" }
        end

        def frame_types
          { "email" => :object, "organization_id" => :object, "user_id" => :object }
        end
      end
    end
  end
end
