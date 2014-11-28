#
# Copyright (C) 2013 CAS / FAMU
#
# This file is part of Narra Core.
#
# Narra Core is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Narra Core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Narra Core. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
#

# Code Climate Test Reporter
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV['RAILS_ENV'] ||= 'test'
ENV['NARRA_MONGOID_HOST'] ||= 'localhost'
ENV['NARRA_MONGOID_PORT'] ||= '27017'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc,
# in narra-core spec/support/ and its subdirectories.
Dir[Gem.loaded_specs['narra-core'].gem_dir + '/spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # File-type inference disabled by default
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'default'

  # Prepare users
  config.before(:each) do
    # create users
    # testing hashes
    admin_hash = ActiveSupport::JSON.decode('{"provider":"test","uid":"admin@narra.eu","info":{"name":"Admin","email":"admin@narra.eu"},"credentials":{},"extra":{}}')
    author_hash = ActiveSupport::JSON.decode('{"provider":"test","uid":"author@narra.eu","info":{"name":"Author","email":"author@narra.eu"},"credentials":{},"extra":{}}')
    unroled_hash = ActiveSupport::JSON.decode('{"provider":"test","uid":"guest@narra.eu","info":{"name":"Unroled","email":"unroled@narra.eu"},"credentials":{},"extra":{}}')
    # create user and its identity
    Narra::Identity.create_from_hash(admin_hash)
    Narra::Identity.create_from_hash(author_hash)
    Narra::Identity.create_from_hash(unroled_hash)
    # get admin token and user
    @admin_token = CGI::escape(Base64.urlsafe_encode64(admin_hash['uid']))
    @admin_user = Narra::User.find_by(name: 'Admin')
    # get author token and user
    @author_token = CGI::escape(Base64.urlsafe_encode64(author_hash['uid']))
    @author_user = Narra::User.find_by(name: 'Author')
    # get guest token and user
    @unroled_token = CGI::escape(Base64.urlsafe_encode64(unroled_hash['uid']))
    @unroled_user = Narra::User.find_by(name: 'Unroled')
    @unroled_user.roles = []
    @unroled_user.save
  end
end