# frozen_string_literal: true

Trestle.resource(:queries, model: Journey::Query) do
  remove_action :create, :destroy

  menu :queries, icon: "fa fa-file-alt", group: :quotations

  collection do
    model.order("created_at DESC")
  end

  scope :all, default: true
  scope :billable, -> { model.where(billable: true) }
  scope :non_billable, -> { model.where(billable: false) }

  scope :lcl, -> { model.where(load_type: :lcl) }
  scope :fcl, -> { model.where(load_type: :fcl) }

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

      safe_join(content, raw("<br />"))
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
        ], raw("<br />"))
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
    text_field :origin, disabled: true
    text_field :destination, disabled: true
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
