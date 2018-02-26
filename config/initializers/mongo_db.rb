if Rails.env == 'development'
  $db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'development')
  elsif Rails.env == 'test'
  $db = Mongo::Client.new('mongodb://imcr-dev:psj8B52WbW7YZNQ9@cluster0-shard-00-00-jw33s.mongodb.net:27017,cluster0-shard-00-01-jw33s.mongodb.net:27017,cluster0-shard-00-02-jw33s.mongodb.net:27017/test?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin')
else
  $db = Mongo::Client.new('mongodb://imcdbadmin:DZYKIdOZk3vP6erN@staging-shard-00-00-sco92.mongodb.net:27017,staging-shard-00-01-sco92.mongodb.net:27017,staging-shard-00-02-sco92.mongodb.net:27017/test?ssl=true&replicaSet=Staging-shard-0&authSource=admin')
end