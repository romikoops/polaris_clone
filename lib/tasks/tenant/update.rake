namespace :tenant do 
  task :update, [] => :environment do |task, args|
    klass = Class.new do 
      include MultiTenantTools
    end
    args.extras.each do |subdomain|
      klass.new.update_tenant_from_json(subdomain)
    end
  end
end