# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class QuotationsController < ApiController
      SORTING_ATTRIBUTES = ["selected_date", "load_type", "last_name", "origin", "destination"]

      def index
        paginated = paginate(filtered_queries)

        decorated_queries = Api::V1::QueryDecorator.decorate_collection(paginated,
          {context: {links: pagination_links(paginated)}})

        render json: QueryListSerializer.new(decorated_queries, params: {scope: current_scope}).serialized_json
      end

      def create
        if validation.errors.present?
          return render json: ValidationErrorSerializer.new(validation.errors), status: :expectation_failed
        end

        render json: QuerySerializer.new(
          Api::V1::QueryDecorator.new(
            quotation_service.result,
            context: {scope: current_scope, load_type: load_type}
          ),
          params: {scope: current_scope}
        )
      rescue Wheelhouse::ApplicationError => e
        render json: {error: e.message}, status: :unprocessable_entity
      end

      def show
        check_for_errors
        decorated_query = QueryDecorator.decorate(query)
        render json: QuerySerializer.new(decorated_query, params: {scope: current_scope})
      rescue OfferCalculator::Errors::Failure => e
        render json: {error: e.message}, status: :unprocessable_entity
      end

      def download
        case download_params[:format]
        when "xlsx"
          if download_params[:dl] == "1"
            excel_direct_download
          else
            render json: XlsxSerializer.new(offer,
              {url: [request.url, "?dl=1"].join})
          end
        when "pdf"
          render json: FileSerializer.new(offer)
        else
          render json: {error: "Download format is missing or invalid"}, status: :unprocessable_entity
        end
      rescue Wheelhouse::ApplicationError => e
        render json: {error: e.message}, status: :unprocessable_entity
      end

      private

      def excel_direct_download
        File.open(offer_excel.path, "r") do |xlsx_data|
          send_data(xlsx_data.read,
            filename: "offer_#{offer.id}.xlsx",
            content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            disposition: "attachment")
        end
        File.delete(tempfile.path)
      end

      def offer_excel
        @offer_excel ||= Wheelhouse::ExcelWriterService.new(offer: offer).quotation_sheet
      end

      def offer
        Wheelhouse::OfferBuilder.offer(results: results)
      end

      def result_ids
        return download_params[:tenders] if download_params[:tenders].present?

        query.result_sets.order(created_at: :desc).first.results.ids
      end

      def validation
        validator = Wheelhouse::ValidationService.new(
          request: query_request,
          final: true
        )
        validator.validate
        validator
      end

      def index_params
        params.permit(:start_date, :end_date, :sort_by, :direction)
      end

      def quotations_filter
        Quotations::Filter.new(organization: current_organization,
                               start_date: index_params[:start_date],
                               end_date: index_params[:end_date])
      end

      def quotation
        Quotations::Quotation.find(params[:id])
      end

      def query
        @query ||= Journey::Query.find(params[:id] || params[:quotation_id])
      end

      def quotation_service
        @quotation_service ||= Wheelhouse::QuotationService.new(
          organization: current_organization,
          quotation_details: quotation_details,
          shipping_info: modified_shipment_params,
          async: async?,
          source: doorkeeper_application
        )
      end

      def query_request
        @query_request ||= OfferCalculator::Request.new(
          query: request_query,
          params: validation_params
        )
      end

      def request_query
        @request_query ||= OfferCalculator::Service::QueryGenerator.new(
          source: doorkeeper_application,
          client: user,
          creator: organization_user,
          params: validation_params,
          persist: false
        ).query
      end

      def quotation_details
        @quotation_details ||= quotation_params.to_h.merge(creator_id: current_user.id)
      end

      def quotation_params
        params.require(:quote).permit(
          :selected_date,
          :user_id,
          :load_type,
          :delay,
          origin: [*address_params, hub_ids: []],
          destination: [*address_params, hub_ids: []]
        )
      end

      def dimension_params
        shipment_params.fetch(:cargo_items_attributes).map do |cargo_item_params|
          {width: cargo_item_params[:width] || cargo_item_params[:dimension_x],
           length: cargo_item_params[:length] || cargo_item_params[:dimension_y],
           height: cargo_item_params[:height] || cargo_item_params[:dimension_z]}
        end
      end

      def modified_cargo_item_params
        shipment_params.fetch(:cargo_items_attributes).map.with_index { |val, i| val.merge(dimension_params[i]) }
      end

      def modified_shipment_params
        return shipment_params if shipment_params["cargo_items_attributes"].nil?

        {cargo_items_attributes: modified_cargo_item_params,
         container_attributes: shipment_params[:container_attributes],
         trucking_info: shipment_params[:trucking_info],
         scale: "m"}.to_h
      end

      def shipment_params
        cargo_items_attributes = %i[id payload_in_kg width length
          dimension_x dimension_z dimension_y
          height quantity total_weight total_volume
          stackable cargo_item_type_id dangerous_goods
          contents cargo_class]
        params.require(:shipment_info).permit(cargo_items_attributes: cargo_items_attributes,
                                              containers_attributes: %i[id size_class quantity contents
                                                payload_in_kg dangerous_goods cargo_class],
                                              trucking_info: [pre_carriage: [:truck_type], on_carriage: [:truck_type]])
      end

      def address_params
        %i[name zip_code number city country full_address latitude longitude nexus_id nexus_name]
      end

      def download_params
        params.permit(:quotation_id, :format, :dl, tenders: [], tender_ids: [])
      end

      def routing
        {
          origin: quotation_params[:origin].to_h,
          destination: quotation_params[:destination].to_h
        }.deep_symbolize_keys
      end

      def load_type
        quotation_params[:load_type]
      end

      def sanitize_direction(direction)
        direction.to_s.upcase == "DESC" ? "DESC" : "ASC"
      end

      def user
        Users::Client.find_by(id: quotation_params[:user_id])
      end

      def async?
        params[:async]
      end

      def check_for_errors
        return if result_set_errors.empty?
        return if latest_result_set.results.present?

        raise OfferCalculator::Errors.from_code(code: result_set_errors.first.code)
      end

      def result_set_errors
        @result_set_errors ||= Journey::Error.where(result_set: latest_result_set)
      end

      def latest_result_set
        @latest_result_set ||= query.result_sets.order(:created_at).last
      end

      def validation_params
        quotation_params.to_h.merge(modified_shipment_params.to_h)
      end

      def filterrific_params
        filters = {}
        if index_params[:sort_by].present?
          filters[:sorted_by] = [index_params[:sort_by], index_params[:direction]].join("_")
        end

        filters
      end

      def filtered_queries
        queries = Api::Query.joins(:result_sets).where(
          billable: true,
          organization_id: current_organization.id,
          journey_result_sets: {status: "completed"}
        )

        if index_params[:start_date].present?
          queries = queries.where("cargo_ready_date >= ?", index_params[:start_date])
        end
        if index_params[:end_date].present?
          queries = queries.where("cargo_ready_date <= ?", index_params[:end_date])
        end

        @filterrific = initialize_filterrific(
          queries,
          filterrific_params
        ) || return

        queries.filterrific_find(@filterrific)
      end

      def results
        Journey::Result.where(id: result_ids)
      end
    end
  end
end
