# frozen_string_literal: true

Trestle.resource(:uploads, model: Admiralty::Upload) do
  remove_action  :edit, :update, :destroy

  menu :all_uploads, icon: "fa fa-file-alt", group: :uploads

  collection do
    model.order("created_at DESC")
  end

  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection
        .joins(:organization)
        .joins(:file)
        .left_joins(:user)
        .where("\
          organizations_organizations.slug ILIKE :query\
          OR users_users.email ILIKE :query \
          OR legacy_files.doc_type ILIKE :query \
          OR legacy_files.text ILIKE :query",
          query: query)
    else
      collection
    end
  end

  %w[
    charge_categories
    clients
    dangerous_goods
    eori
    hubs
    hubs_sheet
    local_charges
    local_charges_sheet
    miscellaneous
    notes
    pricing
    pricings
    pricings_sheet
    schedules
    schedules_sheet
    trucking
    truckings
    v2_uploads
  ].each do |type|
    scope type, -> { model.joins(:file).where(legacy_files: { doc_type: type }) }
  end

  # Customize the table columns shown on the index view.
  #
  sort_column :organizations do |collection, order|
    collection.joins(:organization).merge(Organizations::Organization.order(slug: order))
  end
  sort_column :users do |collection, order|
    collection.left_joins(:user).merge(Users::User.order(email: order))
  end
  table do
    column :created_at, sort: { default: true, default_order: :desc }
    column :organization, sort: :organizations do |upload|
      upload.organization.slug
    end
    column :user, sort: :users do |upload|
      upload.user&.email
    end
    column :file_name, sort: :file_name do |upload|
      upload.file.file.filename.to_s
    end
    column :status, sort: { default_order: :desc }, align: :center do |upload|
      status = upload.status
      status_tag = {
        "not_started" => :secondary,
        "superseded" => :warning,
        "processing" => :primary,
        "failed" => :danger,
        "done" => :success
      }[status]

      status_tag(status.upcase, status_tag)
    end

    actions do |a, instance|
      a.button icon("fa fa-cloud-download-alt"), download_uploads_admin_path(instance), class: "btn-primary"
    end
  end

  controller do
    def download
      self.instance = admin.find_instance(params)
      file_blob = instance.file.file

      if file_blob.present?
        redirect_to(Rails.application.routes.url_helpers.rails_blob_path(file_blob, disposition: "attachment"))
      else
        redirect_to(uploads_admin_index_path)
      end
    end

    def create
      user = Users::User.find_by(email: "shopadmin@itsmycargo.com")
      instance.update(
        status: "not_started",
        user: user,
        file: Legacy::File.create(
          text: instance.text,
          doc_type: instance.doc_type,
          organization: instance.organization,
          user: user,
          file: instance.raw_file
        )
      )
      ExcelDataServices::UploaderJob.perform_later(
        upload_id: instance.id,
        options: { user_id: user.id }.merge({ distribute: true, group_id: instance.group_id.presence })
      )
      super
    end
  end

  form do
    row do
      col(sm: 6) { collection_select :organization_id, Organizations::Organization.all, :id, :slug }
    end
    row do
      col(sm: 6) { file_field :raw_file }
      col(sm: 6) { text_field :text }
      col(sm: 6) { text_field :group_id }
      col(sm: 6) { select :doc_type, %w[truckings local_charges schedules hubs pricings clients companies margins] }
    end
  end

  routes do
    get :download, on: :member
  end
end
