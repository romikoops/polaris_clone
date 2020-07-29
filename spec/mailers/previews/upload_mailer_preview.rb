# frozen_string_literal: true

class UploadMailerPreview < ActionMailer::Preview
  def successful
    UploadMailer
      .with(
        user_id: Users::User.last.id,
        organization: Organizations::Organization.last,
        result: {
          "errors" => [],
          "legacy/itineraries" => {"number_created" => 0, "number_updated" => 0, "number_deleted" => 0},
          "pricings/fees" => {"number_created" => 25, "number_updated" => 0, "number_deleted" => 25},
          "pricings/pricings" => {"number_created" => 22, "number_updated" => 0, "number_deleted" => 22}
        },
        file: "test.xlsx"
      )
      .complete_email
  end

  def failed
    UploadMailer
      .with(
        user_id: Users::User.last.id,
        organization: Organizations::Organization.last,
        result: {
          "has_errors" => true,
          "errors" => [
            {"type" => "error", "row_nr" => 1, "sheet_name" => "Zones",
             "reason" => "The type of the data sheet could not be determined.",
             "exception_class" => {}},
            {"type" => "error", "row_nr" => 1, "sheet_name" => "Fees",
             "reason" => "The type of the data sheet could not be determined.",
             "exception_class" => {}},
            {"type" => "error", "row_nr" => 1, "sheet_name" => "Sheet 1",
             "reason" => "The type of the data sheet could not be determined.",
             "exception_class" => {}}
          ],
          "legacy/itineraries" => {"number_created" => 0, "number_updated" => 0, "number_deleted" => 0},
          "pricings/fees" => {"number_created" => 25, "number_updated" => 0, "number_deleted" => 25},
          "pricings/pricings" => {"number_created" => 22, "number_updated" => 0, "number_deleted" => 22}
        },
        file: "test.xlsx"
      )
      .complete_email
  end
end
