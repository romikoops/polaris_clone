# frozen_string_literal: true

Trestle.resource(:files, model: Legacy::File) do
  remove_action :new, :create, :update, :destroy

  menu :all_files, icon: "fa fa-file-alt", group: :files

  search do |query|
    if query
      collection
        .joins(:organization)
        .joins('LEFT JOIN "users_users" ON "users_users"."id" = "legacy_files"."user_id"')
        .joins('LEFT JOIN "users_clients" ON "users_clients"."id" = "legacy_files"."user_id"')
        .where("\
          text ILIKE :query \
          OR doc_type ILIKE :query \
          OR users_users.email ILIKE :query \
          OR users_clients.email ILIKE :query \
          OR organizations_organizations.slug ILIKE :query",
          query: "%#{query}%")
    else
      collection
    end
  end

  collection do
    model.order("created_at DESC")
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
    scope type, -> { model.where(doc_type: type) }
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :created_at, sort: { default: true, default_order: :desc }
    column :organization, ->(query) { query.organization.slug }
    column :user, ->(file) { file.user&.email }
    column :doc_type
    column :text

    actions do |a, instance|
      a.button icon("fa fa-cloud-download-alt"), download_files_admin_path(instance), class: "btn-primary"
    end
  end

  controller do
    def download
      self.instance = admin.find_instance(params)

      if instance.file.present?
        redirect_to(Rails.application.routes.url_helpers.rails_blob_path(instance.file, disposition: "attachment"))
      else
        redirect_to(files_admin_index_path)
      end
    end
  end

  routes do
    get :download, on: :member
  end
end
