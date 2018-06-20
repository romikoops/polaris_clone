class ShipmentSeeder
  def initialize
    @user = args[:user]
  end
end

# Shipment Columns
# 
#  To Be Removed
#    - pre_carriage_distance_km: decimal
#    - on_carriage_distance_km: decimal 
#    - haulage: string 
#    - schedules_charges: jsonb 
#    - schedule_set: jsonb
#    - route_id: integer
#    - hs_code: string 
#  
#  Current
#    - id: integer
#    - user_id: integer
#       - tenant_id: integer 
#    - status: string
#    - load_type: string
#  (
#    - planned_pickup_date: datetime
#    - planned_origin_drop_off_date: datetime
#    - trucking: jsonb 
#       - has_pre_carriage: boolean
#       - has_on_carriage: boolean

#    - origin_hub_id: integer 
#    - destination_hub_id: integer 
#       - origin_nexus_id: integer 
#       - destination_nexus_id: integer 
#    - planned_eta: datetime 
#    - planned_etd: datetime 
#    - closing_date: datetime 
#  )
#       - trip_id: integer 
#           - itinerary_id: integer 
#    - customs_credit: boolean 
#    - total_price: jsonb 
#    - total_goods_value: jsonb 
#    - eori: string 
#    - direction: string
#    - booking_placed_at: datetime 
#    - cargo_notes: string 
#    - notes: string 
#    - insurance: jsonb 
#    - customs: jsonb 
#    - transport_category_id: integer 
#    - incoterm_id: integer 
#    - incoterm_text: string 
# 
#    - uuid: string
#    - imc_reference: string
#    - created_at: datetime 
#    - updated_at: datetime 


