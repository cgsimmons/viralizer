require 'resque/tasks'

namespace :resque do
  task :setup do
    ENV['LOGGING'] = '1'
    ENV['QUEUE'] = '*'
    Resque.before_fork = proc do
      ActiveRecord::Base.connection.disconnect!
    end
    Resque.after_fork = proc do
      ActiveRecord::Base.establish_connection
    end
  end
end

desc 'Alias for resque:work (To run workers on Heroku)'
task 'jobs:work' => 'resque:work'
