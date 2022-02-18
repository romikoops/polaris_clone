# frozen_string_literal: true

Trestle.resource(:organizations, model: Admiralty::Organization) do
  remove_action :destroy

  menu :organizations, icon: "fa fa-building", group: :organizations

  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection.where("slug ILIKE ?", query)
    else
      collection
    end
  end

  collection do
    model.where("slug NOT LIKE '%-sandbox'").order("live DESC", "slug")
  end

  scope :all, default: true
  scope :live, -> { model.where(live: true) }
  scope :non_live, -> { model.where(live: false) }

  # Customize the table columns shown on the index view.
  #
  table do
    column :slug, link: true
    column :live, sort: { default: true, default_order: :desc }
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |organization|
    tab :generic do
      text_field :slug
      check_box :live

      table organization.domains, admin: :domains do
        column :domain
        column :default

        actions
      end

      concat admin_link_to("New Domain", admin: :domains, action: :new, params: { domain: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end

    tab :theme do
      fields_for :theme do
        text_field :name

        row do
          col(sm: 6) { text_field :primary_color }
          col(sm: 6) { text_field :secondary_color }
        end

        row do
          col(sm: 6) { text_field :bright_primary_color }
          col(sm: 6) { text_field :bright_secondary_color }
        end

        %i[
          background
          small_logo
          large_logo
          email_logo
          white_logo
          wide_logo
          booking_process_image
          landing_page_hero
          landing_page_one
          landing_page_two
          landing_page_three
        ].each do |attachment|
          row do
            col(sm: 4) { file_field attachment }
            col(sm: 8) { organization.theme.send(attachment).attached? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(organization.theme.send(attachment)), width: "100px") : "No Content" }
          end
        end

        col(sm: 2) { select(:landing_page_variant, Organizations::Theme.landing_page_variants.keys.map { |landing_page_variant| [landing_page_variant.humanize, landing_page_variant] }) }
      end
    end

    tab :scope do
      fields_for :scope do
        row do
          col(sm: 3) { check_box :closed_shop }
          col(sm: 3) { check_box :closed_registration }
          col(sm: 3) { check_box :open_quotation_tool }
          col(sm: 3) { check_box :closed_quotation_tool }
        end

        row do
          col(sm: 4) { select :fee_detail, %w[name key key_and_name] }
          col(sm: 3) { select :default_direction, %w[import export] }
          col(sm: 3) { select :default_currency, Treasury::ExchangeRate.where("created_at > ?", 36.hours.ago).select("to").distinct.pluck("to") }
        end

        %i[has_customs has_insurance fixed_currency dangerous_goods detailed_billing
          total_dimensions non_stackable_goods hide_user_pricing_requests
          customs_export_paper fixed_exchange_rates base_pricing require_full_address
          fine_fee_detail hide_sub_totals email_all_quotes hide_grand_total
          currency_conversion show_chargeable_weight
          condense_local_fees_pdf freight_in_original_currency show_beta_features
          show_rate_overview fixed_exchange_rate hard_trucking_limit
          hide_converted_grand_total send_email_on_quote_download cargo_overview_only
          no_aggregated_cargo offer_disclaimers closed_after_map
          feature_uploaders dedicated_pricings_only
          exclude_analytics address_fields default_total_dimensions
          append_hub_suffix expand_non_counterpart_local_charges
          local_charges_required_with_trucking include_location_groups].each_slice(4) do |slice|
          row do
            slice.each do |key|
              col(sm: 3) { check_box key }
            end
          end
        end

        divider

        static_field :consolidations do
          organization.scope.consolidations.each_slice(4) do |slice|
            row do
              slice.each do |key|
                col(sm: 3) { check_box key, { label: Organizations::Scope.key_name(extended_key: key) } }
              end
            end
          end
        end

        divider

        static_field :v2_uploaders do
          organization.scope.v2_uploaders.each_slice(4) do |slice|
            row do
              slice.each do |key|
                col(sm: 3) { check_box key, { label: Organizations::Scope.key_name(extended_key: key) } }
              end
            end
          end
        end

        divider

        static_field :voyage_info do
          organization.scope.voyage_infos.each_slice(4) do |slice|
            row do
              slice.each do |key|
                col(sm: 3) { check_box key, { label: Organizations::Scope.key_name(extended_key: key) } }
              end
            end
          end
        end

        divider

        row do
          col(sm: 3) { number_field :session_length }
          col(sm: 3) { number_field :search_buffer }
          col(sm: 3) { number_field :validity_period }
        end

        divider

        static_field :links do
          organization.scope.links.each_slice(4) do |slice|
            row do
              slice.each do |key|
                col(sm: 3) { text_field key, { label: Organizations::Scope.key_name(extended_key: key) } }
              end
            end
          end
        end

        divider

        row do
          col(sm: 12) do
            collection_select :blacklisted_emails, Users::Client.unscoped.where(organization_id: organization.id), :email, :email, {}, multiple: true
          end
        end
      end
    end

    tab :charge_categories do
      fields_for :charge_categories do
        row do
          col(sm: 6) { text_field :code }
          col(sm: 6) { text_field :name }
        end
      end

      concat admin_link_to("New Charge Category", admin: :charge_categories, action: :new, params: { charge_category: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end

    tab :margins do
      fields_for :margins do
        row do
          col(sm: 2) { select :margin_type,  Pricings::Margin.margin_types.keys }
          col(sm: 2) { select :default_for,  ["rail", "ocean", "air", "truck", "local_charge", "trucking", nil] }
          col(sm: 2) { select :operator, ["+", "%"] }
          col(sm: 2) { number_field :value, label: "Value", help: "The margin value to be applied to the rates" }
          col(sm: 2) { date_field :effective_date, label: "Effective Date", help: "The date the margin comes into effect." }
          col(sm: 2) { date_field :expiration_date, label: "Expiration Date", help: "The date the margin becomes invalid" }
        end
      end

      concat admin_link_to("New Margin", admin: :margins, action: :new, params: { margin: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end

    tab :tenant_cargo_item_types do
      fields_for :tenant_cargo_item_types do
        row do
          col(sm: 6) { collection_select :cargo_item_type_id, Legacy::CargoItemType.all, :id, :description }
        end
      end

      concat admin_link_to("New Cargo Item Types", admin: :tenant_cargo_item_types, action: :new, params: { tenant_cargo_item_type: { organization_id: organization.id } }, class: "btn btn-success") if organization.id
    end
  end

  controller do
    def new
      %w[trucking_pre export cargo import trucking_on].each do |section|
        instance.charge_categories << Legacy::ChargeCategory.new(code: section, name: section.humanize)
      end
      instance.tenant_cargo_item_types << Legacy::TenantCargoItemType.new(
        cargo_item_type: Legacy::CargoItemType.find_by(category: "Pallet", width: nil, length: nil)
      )
      instance.scope = Organizations::Scope.new(content: {})
      instance.theme = Organizations::Theme.new
      super
    end
  end
end
