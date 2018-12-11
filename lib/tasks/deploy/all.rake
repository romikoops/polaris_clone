namespace :deploy do 
  task :all => :environment do 
    klass = Class.new do 
      include MultiTenantTools
    end
    Dir.chdir('client') do 
      system 'npm run deploy'
    end
    klass.new.update_indexes
    system 'eb deploy imc-alpha'
    system 'eb deploy imc-alpha-worker'
  end
end