source 'https://rubygems.org'
git_source(:github) { |repo| 'https://github.com/#{repo}.git' }
ruby '2.7.2'

gem 'coffee-rails', '~> 4.2'
gem 'rails', '~> 5.2.2.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end
group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'capistrano', '~> 3.15.0', require: false
  gem 'capistrano-database-yml'
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rbenv'
  gem 'capistrano-ssh-doctor', git: 'https://github.com/capistrano-plugins/capistrano-ssh-doctor.git'
  gem 'net-ssh', '>= 6.0.2'
  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry'
  gem 'rails_layout'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console', '>= 3.3.0'
end

group :production do
  gem 'puma', '~> 4.3.6'
end

gem 'activerecord-tablefree'
gem 'chartkick'
gem 'groupdate'
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'bootstrap-select-rails'
gem 'diffy'
gem 'elasticsearch'
gem 'i18n'
gem 'jquery-datatables'
gem 'jquery-rails'
gem 'mini_racer', :platform=>:ruby
gem 'oj'
gem 'rack-timeout', require: 'rack/timeout/base'
gem 'responders'
gem 'rest-client'
gem 'rufus-scheduler'
gem 'searchkick', '~> 4.4.2'
gem 'sidekiq'
gem 'typhoeus'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]