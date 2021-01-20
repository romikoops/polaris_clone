module Pricings
  class MarginCreator
    def initialize(args)
      @itinerary_ids = args[:itinerary_ids]
      @hub_ids = args[:hub_ids]
      @cargo_classes = args[:cargo_classes].presence || [nil]
      @tenant_vehicle_ids = args[:tenant_vehicle_ids].presence || [nil]
      @pricing_id = args[:pricing_id]
      @directions = args[:directions] || args[:hub_direction]
      @margin_type = args[:marginType]
      @attached_to = args[:attached_to]
      @counterpart_hub_id = args[:counterpart_hub]&.dig(:id)
      @pricing = if args[:pricing_id]
        Pricings::Pricing.where(organization_id: current_organization.id).find(args[:pricing_id])
      end
      @new_organization = Organizations::Organization.find(args[:organization_id])
      @group = Groups::Group.find(args[:groupId])
      @args = args
    end

    attr_reader :pricing, :itinerary_ids, :hub_ids, :cargo_classes, :tenant_vehicle_ids, :pricing_id,
      :directions, :margin_type, :attached_to, :new_organization, :group, :args, :counterpart_hub_id

    def perform
      create_from_iterations
    end

    def create_from_iterations
      effective_date = (Date.parse(args[:effective_date]) || pricing&.effective_date).beginning_of_day
      expiration_date = (Date.parse(args[:expiration_date]) || pricing&.expiration_date).end_of_day
      iterations.map do |iteration|
        margin = Pricings::Margin.create!(
          operator: args[:operand][:value],
          value: get_margin_value(args[:operand][:value], args[:marginValue]),
          organization: new_organization,
          pricing: pricing,
          applicable: group,
          effective_date: effective_date,
          expiration_date: expiration_date,
          tenant_vehicle_id: iteration[:tenant_vehicle_id],
          itinerary_id: iteration[:itinerary_id],
          cargo_class: iteration[:cargo_class],
          origin_hub_id: iteration[:origin_hub_id],
          margin_type: iteration[:margin_type],
          destination_hub_id: iteration[:destination_hub_id]
        )

        if args[:fineFeeValues].present?
          args[:fineFeeValues].each_key do |key|
            fee_code = key.to_s.split(" - ").first
            charge_category = ::Legacy::ChargeCategory.from_code(code: fee_code, organization_id: new_organization.id)
            ::Pricings::Detail.create!(
              margin_id: margin.id,
              organization: new_organization,
              value: get_margin_value(args[:fineFeeValues][key][:operand][:value], args[:fineFeeValues][key][:value]),
              operator: args[:fineFeeValues][key][:operand][:value],
              charge_category_id: charge_category.id
            )
          end
        end

        margin
      end
    end

    def get_margin_value(operator, value)
      return value.to_d / 100.0 if operator == "%"

      value
    end

    def iterations
      @iterations ||= if margin_type == "freight" && hub_ids.present?
        freight_iterations_by_hub
      elsif margin_type == "freight" && itinerary_ids.present?
        freight_iterations_by_itinerary
      elsif margin_type == "freight" && itinerary_ids.blank? && attached_to == "itinerary"
        @itinerary_ids = [nil]
        freight_iterations_by_itinerary
      elsif margin_type == "trucking"
        trucking_iterations
      elsif margin_type == "local_charges"
        local_charge_iterations
      end
    end

    def local_charge_iterations
      iterations = []
      directions.each do |direction|
        hub_ids.each do |hub_id|
          cargo_classes.each do |cargo_class|
            tenant_vehicle_ids.each do |tv_id|
              case direction
              when "import"
                iterations << {
                  destination_hub_id: hub_id,
                  origin_hub_id: counterpart_hub_id,
                  cargo_class: cargo_class,
                  tenant_vehicle_id: tv_id,
                  margin_type: :import_margin
                }
              when "export"
                iterations << {
                  origin_hub_id: hub_id,
                  destination_hub_id: counterpart_hub_id,
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
      directions.each do |direction|
        hub_ids.each do |hub_id|
          cargo_classes.each do |cargo_class|
            case direction
            when "import"
              iterations << {
                origin_hub_id: hub_id,
                destination_hub_id: counterpart_hub_id,
                cargo_class: cargo_class,
                margin_type: :trucking_on_margin
              }
            when "export"
              iterations << {
                destination_hub_id: hub_id,
                origin_hub_id: counterpart_hub_id,
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
      directions.each do |direction|
        hub_ids.each do |hub_id|
          cargo_classes.each do |cargo_class|
            tenant_vehicle_ids.each do |tv_id|
              case direction
              when "import"
                iterations << {
                  destination_hub_id: hub_id,
                  origin_hub_id: counterpart_hub_id,
                  cargo_class: cargo_class,
                  tenant_vehicle_id: tv_id,
                  margin_type: :freight_margin
                }
              when "export"
                iterations << {
                  origin_hub_id: hub_id,
                  destination_hub_id: counterpart_hub_id,
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
      itinerary_ids.each do |it_id|
        cargo_classes.each do |cargo_class|
          tenant_vehicle_ids.each do |tv_id|
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

    def self.create_default_margins(organization)
      ["rail", "ocean", "air", "truck", "local_charge", "trucking", nil].each do |default|
        %i[freight_margin export_margin import_margin trucking_pre_margin trucking_on_margin].each do |m_type|
          ::Pricings::Margin.find_or_create_by!(
            organization: organization,
            value: 0,
            default_for: default,
            operator: "%",
            applicable: organization,
            margin_type: m_type,
            effective_date: Date.current,
            expiration_date: Date.current + 5.years
          )
        end
      end
    end
  end
end
