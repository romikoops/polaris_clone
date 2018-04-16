class ExcelWorker # TODO: mongo
  include Shoryuken::Worker
  include ExcelTools

  shoryuken_options queue: "https://sqs.eu-central-1.amazonaws.com/003688427525/excel_worker", auto_delete: true, body_parser: JSON


  def perform(sqs_msg, body)
    check = get_item("jobs", "_id", body["job_id"])
    if check && !check["completed"]
      rows = body["rows_for_job"]
      user = User.find(body["user_id"])
      update_item("jobs", {_id: body["job_id"]}, {completed: true})
      handle_zipcode_sections(rows, user, body["direction"], body["hub_id"], body["courier_name"], body["load_type"], body["defaults"], body["weight_min_row"], body["currency"])
    else
      
    end
  end
end

