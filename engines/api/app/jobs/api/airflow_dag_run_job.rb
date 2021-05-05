# frozen_string_literal: true

module Api
  class AirflowDagRunJob < Api::ApplicationJob
    queue_as :default

    def perform(dag_name:, payload:)
      endpoint = "/api/v1/dags/#{dag_name}/dagRuns"

      connection.post(endpoint, payload, { "Content-Type" => "application/json" })
    end

    private

    def connection
      Faraday.new(url: Settings.airflow) { |conn| conn.authorization(:Bearer, google_openid_token) }
    end

    def google_openid_token
      ::Google::Iam::Credentials::V1::IAMCredentials::Client
        .new
        .generate_id_token(
          audience: "itsmycargo-main.apps.googleusercontent.com",
          name: "projects/-/serviceAccounts/polaris@itsmycargo-main.iam.gserviceaccount.com",
          include_email: true
        )
        .token
    end
  end
end
