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
      class ScenariosV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :scenarios do

          desc 'Return all scenarios.'
          get do
            return_many(Scenario, Narra::API::Entities::Scenario, true, [:author])
          end

          desc 'Validation if a specific project exists.'
          post 'validate' do
            authenticate!
            # prepare
            validation = false
            # check if there is a project by the name or title
            validation = true if params[:name] && params[:type] && Narra::Scenario.where(name: params[:name], type: params[:type]).count == 0
            # if the project exists return ok
            present_ok_generic(:validation, validation)
          end

          desc 'Return a specific library.'
          get ':id' do
            return_one(Scenario, Narra::API::Entities::Scenario, :id, true, [:author])
          end

          desc 'Create new scenario.'
          post 'new' do
            required_attributes! [:name, :type]
            # check for the author
            author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
            # prepare parameters
            case params[:type].to_sym
              when :library
                # check for generators
                generators = params[:generators].nil? ? [] : params[:generators].select {|g| !Narra::Core.generator(g[:identifier].to_sym).nil?}
                # prepare params
                parameters = {name: params[:name], type: ScenarioLibrary, description: params[:description], author: author, generators: generators}
              when :project
                # check for synthesizers
                synthesizers = params[:synthesizers].nil? ? [] : params[:synthesizers].select {|s| !Narra::Core.synthesizer(s[:identifier].to_sym).nil?}
                visualizations = params[:visualizations].nil? ? [] : params[:visualizations]
                layouts = params[:layouts].nil? ? [] : params[:layouts]
                parameters = {name: params[:name], type: ScenarioProject, description: params[:description], author: author, synthesizers: synthesizers, visualizations: visualizations, layouts: layouts}
              else
                error_parameter_missing!(:type)
            end
            # create Scenario
            new_one(Scenario, Narra::API::Entities::Scenario, true, [:author], parameters)
          end

          desc 'Delete a specific library.'
          get ':id/delete' do
            return_one_custom(Scenario, :id, true, [:author]) do |scenario, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author]).size > 0
              # check for dependencies
              if scenario.respond_to?('projects') && !scenarion.projects.empty? || scenario.respond_to?('libraries') && !scenario.libraries.empty?
                error_generic!('Scenario is still used by the Project or Library', 404)
              else
                # delete
                scenario.destroy
                # present
                present_ok
              end
            end
          end
        end
      end
    end
  end
end