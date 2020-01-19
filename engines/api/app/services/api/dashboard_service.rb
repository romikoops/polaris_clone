# frozen_string_literal: true

module Api
  class DashboardService
    def initialize(user:)
      @user = user
      @legacy_user = Legacy::User.find(user.legacy_id)
    end

    def data
      {
        shipments: shipments_hash,
        components: component_configuration,
        revenue: find_revenue,
        tradelanes: find_tradelanes,
        bookings_per_route: bookings_per_route
      }
    end

    def find_revenue
      rev_arr = []
      rev_total = 0
      shipments_hash.each_value do |shipments|
        shipments.each do |shipment|
          value = shipment.total_price&.fetch(:value) || 0
          rev_arr << { id: shipment['id'], total_price_value: value, created_at: shipment['created_at'] }
          rev_total += value
        end
      end
      { rev_arr: rev_arr, rev_total: rev_total }
    end

    def find_tradelanes
      user_tradelanes = []

      ::Legacy::Shipment.where(tenant_id: @legacy_user.tenant_id).find_each do |s|
        next if s['destination_nexus_id'].nil? || s['origin_nexus_id'].nil?

        user_tradelanes << {
                             destination: s['destination_nexus_id'],
                             origin: s['origin_nexus_id']
                           }
      end
      user_tradelanes.group_by(&:itself).map { |k, v| k.merge(count: v.length) }
    end

    def bookings_per_route
      shipments_by_itinerary = Legacy::Shipment.where(tenant_id: @legacy_user.tenant_id)
                                               .requested
                                               .joins(:itinerary)
                                               .group(:itinerary_id).count
      shipments_by_itinerary.map do |itinerary_id, shipments_count|
        {
          itinerary: Legacy::Itinerary.find(itinerary_id),
          bookings: shipments_count
        }
      end
    end

    def component_configuration
      {
        'BookingsPerMonth': { component_name: 'BookingsPerMonth',
                              config: { gridItem: true, gridXS: 6, gridSM: 6, gridMD: 6 } },
        'BookingsPerUser': { component_name: 'BookingsPerUser',
                             config: { gridItem: true, gridXS: 6, gridSM: 6, gridMD: 6 } },
        'UnresolvedBookingsNumber': { component_name: 'UnresolvedBookingsNumber',
                                      config: { gridItem: false } },
        'BookingsInProgressNumber': { component_name: 'BookingsInProgressNumber',
                                      config: { gridItem: false } },
        'BookingRevenue': { component_name: 'BookingRevenue',
                            config: { gridItem: false } },
        'BookingsPerCarrierChart': { component_name: 'BookingsPerCarrierChart',
                                     config: { gridItem: false } },
        'BookingsPerDay': { component_name: 'BookingsPerDay',
                            config: { gridItem: false } }
      }
    end

    def shipments_hash
      tenant_scope = ::Tenants::ScopeService.new(
        target: @user,
        tenant: @user.tenant
      ).fetch

      if tenant_scope['open_quotation_tool'] || tenant_scope['closed_quotation_tool']
        { quoted: quoted_shipments.order(booking_placed_at: :desc),
          bookings_in_progress: bookings_in_progress.order(booking_placed_at: :desc) }
      else {
        requested: requested_shipments.order(booking_placed_at: :desc),
        bookings_in_progress: bookings_in_progress.order(booking_placed_at: :desc),
        open: open_shipments.order(booking_placed_at: :desc),
        rejected: rejected_shipments.order(booking_placed_at: :desc),
        archived: archived_shipments.order(booking_placed_at: :desc),
        finished: finished_shipments.order(booking_placed_at: :desc)
      }
      end
    end

    def tenant_shipments
      @tenant_shipments ||= Legacy::Shipment.where(tenant_id: @legacy_user.tenant_id, sandbox: @sandbox)
                                            .where('shipments.created_at > ?', Date.today.beginning_of_month)
    end

    def shipments
      @shipments ||= tenant_shipments.external_user
    end

    def requested_shipments
      @requested_shipments ||= shipments.requested
    end

    def quoted_shipments
      @quoted_shipments ||= shipments.quoted
    end

    def open_shipments
      @open_shipments ||= shipments.open
    end

    def rejected_shipments
      @rejected_shipments ||= shipments.rejected
    end

    def archived_shipments
      @archived_shipments ||= shipments.archived
    end

    def finished_shipments
      @finished_shipments ||= shipments.finished
    end

    def bookings_in_progress
      @bookings_in_progress || shipments.where(status: 'booking_process_started')
    end
  end
end
