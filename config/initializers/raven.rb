if Rails.env.production?
  if ENV['WORKER_MODE'] == "1"
    Raven.configure do |config|
      config.dsn = 'http://6d3b102312b84a62a8f6d982e2676152:79f79cc3abf14a4f94cd84397e28f658@ec2-52-29-81-197.eu-central-1.compute.amazonaws.com/5'
    end
  elsif ENV['BETA'] == 'true'
    Raven.configure do |config|
      config.dsn = 'http://0dd9b1493b524bf593a8d9c693170ede:1b03e58368cb4eafb3832717b4a416e7@ec2-52-29-81-197.eu-central-1.compute.amazonaws.com/6'
    end
  else
    Raven.configure do |config|
      config.dsn = 'http://e38fa6c168f64dec8070b81ba26694cc:2516c99c0be842c99e3b2cc6884f2e99@ec2-52-29-81-197.eu-central-1.compute.amazonaws.com/3'
      # config.environments = ['staging', 'production']
    end
  end
end  