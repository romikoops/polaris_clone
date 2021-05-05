# frozen_string_literal: true

module Api
  module UploadPipelines
    class Okargo < Api::UploadPipelines::Airflow
      private

      def dag_name
        "ingest_okargo_v1"
      end
    end
  end
end
