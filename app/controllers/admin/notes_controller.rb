# frozen_string_literal: true

class Admin::NotesController < Admin::AdminBaseController
  def upload
    handle_upload(
      params: upload_params,
      text: "#{current_tenant.subdomain}:notes",
      type: 'notes',
      options: {
        sandbox: @sandbox,
        group_id: upload_params[:group_id],
        user: current_user
      }
    )
  end

  private

  def upload_params
    params.permit(:file, :mot, :load_type, :group_id)
  end
end
