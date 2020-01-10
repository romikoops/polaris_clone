# frozen_string_literal: true

module Pricings
  class MarginCreator
    def initialize(args)
      @itinerary_ids = args[:itinerary_ids]
      @hub_ids = args[:hub_ids]
      @cargo_classes = args[:cargo_classes].empty? ? [nil] : args[:cargo_classes]
      @tenant_vehicle_ids = args[:tenant_vehicle_ids].empty? ? [nil] : args[:tenant_vehicle_ids]
      @pricing_id = args[:pricing_id]
      @directions = args[:directions]
      @margin_type = args[:marginType]
      @attached_to = args[:attached_to]
      @pricing = args[:pricing_id] ? current_tenant.rates.find(args[:pricing_id]) : nil
      @new_tenant = Tenants::Tenant.find_by(legacy_id: args[:tenant_id])
      @group = Tenants::Group.find(args[:groupId])
      @args = args
    end

    def perform
      @iterations = determine_iterations
      create_from_iterations
    end

    def create_from_iterations
      effective_date = (Date.parse(@args[:effective_date]) || pricing&.effective_date).beginning_of_day
      expiration_date = (Date.parse(@args[:expiration_date]) || pricing&.expiration_date).end_of_day
      @iterations.map do |iteration| # rubocop:disable Metrics/BlockLength
        margin = Pricings::Margin.create!(
          operator: @args[:operand][:value],
          value: get_margin_value(@args[:operand][:value], @args[:marginValue]),
          tenant: @new_tenant,
          pricing: @pricing,
          applicable: @group,
          effective_date: effective_date,
          expiration_date: expiration_date,
          tenant_vehicle_id: iteration[:tenant_vehicle_id],
          itinerary_id: iteration[:itinerary_id],
          cargo_class: iteration[:cargo_class],
          origin_hub_id: iteration[:origin_hub_id],
          margin_type: iteration[:margin_type],
          destination_hub_id: iteration[:destination_hub_id]
        )

        unless @args[:fineFeeValues].empty?
          @args[:fineFeeValues].keys.each do |key|
            fee_code = key.to_s.split(' - ').first
            charge_category = ::Legacy::ChargeCategory.from_code(code: fee_code, tenant_id: @new_tenant.legacy_id)
            ::Pricings::Detail.create!(
              margin_id: margin.id,
              tenant: @new_tenant,
              value: get_margin_value(@args[:fineFeeValues][key][:operand][:value], @args[:fineFeeValues][key][:value]),
              operator: @args[:fineFeeValues][key][:operand][:value],
              charge_category_id: charge_category.id
            )
          end
        end

        margin
      end
    end

    def get_margin_value(operator, value)
      return value.to_d / 100.0 if operator == '%' && value.to_d > 1

      value
    end

    def determine_iterations
      if @margin_type == 'freight' && !@hub_ids.empty?
        freight_iterations_by_hub
      elsif @margin_type == 'freight' && !@itinerary_ids.empty?
        freight_iterations_by_itinerary
      elsif @margin_type == 'freight' && @itinerary_ids.empty? && @attached_to == 'itinerary'
        @itinerary_ids = [nil]
        freight_iterations_by_itinerary
      elsif @margin_type == 'trucking'
        trucking_iterations
      elsif @margin_type == 'local_charges'
        local_charge_iterations
      end
    end

    def local_charge_iterations
      iterations = []
      @directions.each do |direction|
        @hub_ids.each do |hub_id|
          @cargo_classes.each do |cargo_class|
            @tenant_vehicle_ids.each do |tv_id|
              case direction
              when 'import'
                iterations << {
                  destination_hub_id: hub_id,
                  origin_hub_id: @counterpart_hub_id,
                  cargo_class: cargo_class,
                  tenant_vehicle_id: tv_id,
                  margin_type: :import_margin
                }
              when 'export'
                iterations << {
                  origin_hub_id: hub_id,
                  destination_hub_id: @counterpart_hub_id,
                  tenant_vehicle_id: tv_id,
                  cargo_class: cargo_class,
                  margin_type: :export_margin
                }
              end
            end
          end
        end
      end
      iterations
    end

    def trucking_iterations
      iterations = []
      @directions.each do |direction|
        @hub_ids.each do |hub_id|
          @cargo_classes.each do |cargo_class|
            case direction
            when 'import'
              iterations << {
                origin_hub_id: hub_id,
                destination_hub_id: @counterpart_hub_id,
                cargo_class: cargo_class,
                margin_type: :trucking_on_margin
              }
            when 'export'
              iterations << {
                destination_hub_id: hub_id,
                origin_hub_id: @counterpart_hub_id,
                cargo_class: cargo_class,
                margin_type: :trucking_pre_margin
              }
            end
          end
        end
      end
      iterations
    end

    def freight_iterations_by_hub
      iterations = []
      @directions.each do |direction|
        @hub_ids.each do |hub_id|
          @cargo_classes.each do |cargo_class|
            @tenant_vehicle_ids.each do |tv_id|
              case direction
              when 'import'
                iterations << {
                  destination_hub_id: hub_id,
                  origin_hub_id: @counterpart_hub_id,
                  cargo_class: cargo_class,
                  tenant_vehicle_id: tv_id,
                  margin_type: :freight_margin
                }
              when 'export'
                iterations << {
                  origin_hub_id: hub_id,
                  destination_hub_id: @counterpart_hub_id,
                  tenant_vehicle_id: tv_id,
                  cargo_class: cargo_class,
                  margin_type: :freight_margin
                }
              end
            end
          end
        end
      end
      iterations
    end

    def freight_iterations_by_itinerary
      iterations = []
      @itinerary_ids.each do |it_id|
        @cargo_classes.each do |cargo_class|
          @tenant_vehicle_ids.each do |tv_id|
            iterations << {
              itinerary_id: it_id,
              cargo_class: cargo_class,
              tenant_vehicle_id: tv_id,
              margin_type: :freight_margin
            }
          end
        end
      end
      iterations
    end
  end
end
