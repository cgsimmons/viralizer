require 'resque/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    ENV['QUEUE'] = '*'

    Resque.redis = 'localhost:6379' unless Rails.env == 'production'
  end
end

Resque.after_fork = proc { ActiveRecord::Base.establish_connection }

desc 'Alias for resque:work (To run workers on Heroku)'
task 'jobs:work' => 'resque:work'
