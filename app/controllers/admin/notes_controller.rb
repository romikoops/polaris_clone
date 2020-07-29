# frozen_string_literal: true

class Admin::NotesController < Admin::AdminBaseController
  def upload
    handle_upload(
      params: upload_params,
      text: "#{current_organization.slug}:notes",
      type: 'notes',
      options: {
        group_id: upload_params[:group_id],
        user: organization_user
      }
    )
  end

  private

  def upload_params
    params.permit(:async, :file, :mot, :load_type, :group_id)
  end
end
