#
# Copyright (C) 2014 CAS / FAMU
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

module Narra
  module API
    module Modules
      class ScenariosV1Update < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes
        helpers Narra::API::Helpers::Array

        resource :scenarios do

          desc 'Update a specific scenario.'
          post ':id/update' do
            update_one(Scenario, Narra::API::Entities::Scenario, :id, true, [:author]) do |scenario|
              scenario.update_attributes(name: params[:name]) unless params[:name].nil? || scenario.name.equal?(params[:name])
              scenario.update_attributes(description: params[:description]) unless params[:description].nil? || scenario.description.equal?(params[:description])
              scenario.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || scenario.author.username.equal?(params[:author])
              scenario.shared = params[:shared] unless params[:shared].nil?
              # check for scenario type
              case scenario.type
                when :scenariolibrary
                  # gather generators if exist
                  unless params[:generators].nil?
                    generators = params[:generators].select { |g| !Narra::Core.generator(g[:identifier].to_sym).nil? }
                    # push them if changed
                    scenario.update_attributes(generators: generators)
                  end
                when :scenarioproject
                  # gather synthesizers if exist
                  unless params[:synthesizers].nil?
                    synthesizers = params[:synthesizers].select { |s| !Narra::Core.synthesizer(s[:identifier].to_sym).nil? }
                    # push them if changed
                    scenario.update_attributes(synthesizers: synthesizers)
                  end
                  # update layouts and visualizations if exist
                  scenario.update_attributes(layouts: params[:layouts]) unless params[:layouts].nil?
                  scenario.update_attributes(visualizations: params[:visualizations]) unless params[:visualizations].nil?
              end
            end
          end
        end
      end
    end
  end
end