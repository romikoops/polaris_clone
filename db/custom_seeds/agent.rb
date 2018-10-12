agency_tenants = Tenant.all.select{ |t| t.scope['open_quotation_tool'] || t.scope['closed_quotation_tool']}
@manager_role = Role.find_by_name('agency_manager')
@agent_role = Role.find_by_name('agent')
agency_tenants.each do |tenant|
  @agency = Agency.find_or_create_by!(
    name:  'ItsMyCargo',
    tenant_id: tenant.id
  )
  @agency_manager = tenant.users.find_by(
    email:  'manager@itsmycargo.com',
    agency_id: @agency.id,
    role: @manager_role
  )
  @agency_manager ||= tenant.users.create!(
    first_name:  'Manager',
    last_name:  'IMC',
    tenant_id: tenant.id,
    email:  'manager@itsmycargo.com',
    phone:  '123456789',
    vat_number: '987654321',
    external_id: 'Blue',
    agency_id: @agency.id,
    role: @manager_role,
    password: 'IMC123456789'
  )
  @agent = tenant.users.find_by(
    email:  'agent@itsmycargo.com',
    agency_id: @agency.id,
    role: @agent_role
  )
  @agent ||= tenant.users.create!(
    first_name:  'Agent',
    last_name:  'IMC',
    tenant_id: tenant.id,
    email:  'agent@itsmycargo.com',
    phone:  '123456789',
    vat_number: '987654321',
    external_id: 'Blue',
    agency_id: @agency.id,
    role: @agent_role,
    password: 'IMC123456789'
  )
  @agency.update_attributes(agency_manager_id: @agency_manager.id)
  agency_to_copy = tenant.agencies.where.not(name: 'ItsMyCargo').first
  if agency_to_copy
    agency_to_copy.agency_manager.pricings.each do |pricing|
      pricing.duplicate_for_user(@agency_manager.id)
    end 
  end
end