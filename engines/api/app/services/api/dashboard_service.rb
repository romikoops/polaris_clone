# frozen_string_literal: true

module Api
  class DashboardService
    def initialize(user:)
      @user = user
    end

    def data
      {
        shipments: shipments_hash,
        components: component_configuration,
        revenue: find_revenue,
        tradelanes: find_tradelanes
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

      ::Legacy::Shipment.where(user_id: @user.legacy_id).find_each do |s|
        next if s['destination_nexus_id'].nil? || s['origin_nexus_id'].nil?

        user_tradelanes << {
                             destination: s['destination_nexus_id'],
                             origin: s['origin_nexus_id']
                           }
      end
      user_tradelanes.group_by(&:itself).map { |k, v| k.merge(count: v.length) }
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

    def requested_shipments
      @requested_shipments ||= ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                                 .where(status: %w(requested requested_by_unconfirmed_account))
    end

    def quoted_shipments
      @quoted_shipments ||= ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                              .where(status: 'quoted')
    end

    def open_shipments
      @open_shipments ||= ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                            .where(status: %w(in_progress confirmed))
    end

    def rejected_shipments
      @rejected_shipments ||= ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                                .where(status: %w(ignored declined))
    end

    def archived_shipments
      @archived_shipments ||= ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                                .where(status: 'archived')
    end

    def finished_shipments
      @finished_shipments ||= ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                                .where(status: 'finished')
    end

    def bookings_in_progress
      @bookings_in_progress || ::Legacy::Shipment.where(user_id: @user.legacy_id)
                                                 .where(status: 'booking_process_started')
    end
  end
end
