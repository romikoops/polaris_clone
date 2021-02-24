# frozen_string_literal: true

Trestle.resource(:queries, model: Journey::Query) do
  remove_action :new, :create, :update, :destroy

  menu :queries, icon: "fa fa-file-alt", group: :quotations

  collection do
    model.order("created_at DESC")
  end

  search do |query|
    if query
      collection
        .joins(:organization)
        .joins('INNER JOIN "users_clients" ON "users_clients"."id" = "journey_queries"."client_id"')
        .where("\
          origin ILIKE :query \
          OR destination ILIKE :query \
          OR users_clients.email ILIKE :query \
          OR organizations_organizations.slug ILIKE :query",
          query: "%#{query}%")
    else
      collection
    end
  end

  scope :all, default: true
  scope :billable, -> { model.where(billable: true) }
  scope :non_billable, -> { model.where(billable: false) }

  scope :lcl, -> { model.where(load_type: :lcl) }
  scope :fcl, -> { model.where(load_type: :fcl) }

  {
    bridge: "59ddf39e-c768-4710-98e6-f99baaa5c41f",
    dipper: "7a90a8c0-66ce-4472-8416-659674bf711f",
    siren: "54944c3a-f437-4be9-99ea-64fccdee7c53"
  }.each do |name, id|
    scope name, -> { model.where(source_id: id) }
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :created_at, sort: {default: true, default_order: :desc}
    column :organization, -> (query) { query.organization.slug }
    column :user do |query|
      creator = query.creator_type.present? ? query.creator_type.safe_constantize.unscoped.find_by(id: query.creator_id) : nil
      client = query.client_id.present? ? Users::Client.unscoped.find_by(id: query.client_id) : nil

      content = []
      if client
        content << content_tag(:span, client.email)
      end
      if creator && creator != client
        content << content_tag(:small, creator.email)
      end

      safe_join(content, tag(:br))
    end
    column :origin
    column :destination
    column :load_type, -> (query) { query.load_type.upcase }, align: :center
    column :billable, align: :center
    column :status, align: :center do |query|
      result_set = query.result_sets.order(:created_at).first
      if result_set
        status_tag("#{result_set.status.upcase}", result_set.completed? ? :success : :danger)
      else
        status_tag("N/A", :danger)
      end
    end

    column :results do |query|
      result_set = query.result_sets.order(:created_at).first
      if result_set
        errors = result_set.result_errors.map(&:property).sort.uniq.map { |error| content_tag(:small, error) }
        safe_join([
          content_tag(:span, "#{result_set.results.count} Results"),
          *errors
        ], tag(:br))
      else
        "N/A"
      end
    end
    column :source, -> (query) { Doorkeeper::Application.find(query.source_id).name }

    actions do |a, instance|
      a.button icon("fa fa-file-pdf"), download_queries_admin_path(instance), class: instance.offers.present? ? "btn-primary" : "btn disabled"
    end
  end

  form do |query|
    tab :details do
      text_field :origin, disabled: true
      text_field :destination, disabled: true

      table query.cargo_units do
        column :quantity
        column :cargo_class
        column :weight
        column :length
        column :height
        column :width
        column :colli_type
      end
    end

    tab :results do
      table query.results, admin: :results do
        column :id
        column :mot, -> (result) { result.route_sections.where.not(mode_of_transport: "carriage").pluck(:mode_of_transport).uniq.join(", ") }
        column :origin, -> (result) { result.route_sections.where.not(mode_of_transport: :carriage).order(:order).first&.from }
        column :destination, -> (result) { result.route_sections.where.not(mode_of_transport: :carriage).order(:order).last&.to }
      end
    end
  end

  controller do
    def download
      self.instance = admin.find_instance(params)

      if instance.offers.present?
        offer = instance.offers.order(:created_at).first
        redirect_to(Rails.application.routes.url_helpers.rails_blob_path(offer.file, disposition: "attachment"))
      else
        redirect_to(queries_admin_index_path)
      end
    end
  end

  routes do
    get :download, on: :member
  end
end
