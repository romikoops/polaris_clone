# frozen_string_literal: true

class Admin::ScopesController < Admin::AdminBaseController
  SCOPE_SELECT_OPTIONS = {
    fee_detail: %w(key name key_and_name),
    cargo_info_level: %w(text hs_code),
    carriage_options: {
      on_carriage: {
        export: %w(optional mandatory),
        import: %w(optional mandatory)
      },
      pre_carriage: {
        export: %w(optional mandatory),
        import: %w(optional mandatory)
      }
    },
    incoterm_info_level: %w(text simple full),
    chargeable_weight_view: %w(dynamic weight volume both)
  }.freeze

  def show
    response_handler({}) unless params[:target_type]
    
    target = get_target(type: params[:target_type], id: params[:target_id])
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: current_user.tenant_id)
    service_scope = Tenants::ScopeService.new(target: target, tenant: tenants_tenant).fetch
    scope = Tenants::Scope.find_by(target: target, sandbox: @sandbox) || {}
    response_handler(targetScope: scope, serviceScope: service_scope, selectOptions: SCOPE_SELECT_OPTIONS)
  end

  private

  def get_target(type:, id:)
    case type
    when 'group'
      Tenants::Group.find_by(id: id, sandbox: @sandbox)
    when 'company'
      Tenants::Company.find_by(id: id, sandbox: @sandbox)
    when 'user'
      Tenants::User.find_by(legacy_id: id, sandbox: @sandbox)
    end
  end
end
