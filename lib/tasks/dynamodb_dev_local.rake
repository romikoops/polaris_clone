# desc 'Execute a task in the background'
# task :background, :task do |t, args|
#   rake_path = `which rake`.chomp
#   app_path = Dir.pwd
#   cmd = "#{rake_path} #{args.task} --trace --rakefile #{app_path}/Rakefile >> #{app_path}/log/rake.log 2>&1 &"
#   puts 'Executing:'
#   puts "    #{cmd}"
#   system cmd
# end