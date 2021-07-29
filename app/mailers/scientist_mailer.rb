# frozen_string_literal: true

class ScientistMailer < ApplicationMailer
  default from: "notifications@itsmycargo.shop"
  layout "notification"

  def complete_email
    @experiment_name = params[:experiment_name]
    @app_name = params[:app_name]
    @has_errors = params[:has_errors]
    @notification_type = @has_errors ? "bad" : "good"
    verdict = @has_errors ? "with errors" : "successfully"
    @notification_title = "Experiment \"#{@experiment_name}\" completed #{verdict}."
    @query_input_params = params[:query_input_params]
    @control_diff = diff.left
    @candidate_diff = diff.right

    mail(to: "dev-services@itsmycargo.com", subject: "[ItsMyCargo] Experiment \"#{@experiment_name}\" completed #{verdict}")
  end

  private

  def diff
    @diff ||= Diffy::SplitDiff.new(
      prepare_for_diff(value: params[:control_value]),
      prepare_for_diff(value: params[:candidate_value]),
      format: :html
    )
  end

  def prepare_for_diff(value:)
    JSON.pretty_generate(value).concat("\n").gsub(/\n+$/, "\n")
  end
end
