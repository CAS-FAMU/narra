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
      class LibrariesV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :libraries do

          desc 'Return all libraries.'
          get do
            return_many(Library, Narra::API::Entities::Library, true, [:author])
          end

          desc 'Validation if a specific library exists.'
          post 'validate' do
            authenticate!
            # prepare
            validation = false
            # check if there is a project by the name or title
            validation = true if params[:name] && Narra::Library.where(name: params[:name]).count == 0
            # if the project exists return ok
            present_ok_generic(:validation, validation)
          end

          desc 'Return a specific library.'
          get ':id' do
            return_one(Library, Narra::API::Entities::Library, :id, true, [:author])
          end

          desc 'Create new library.'
          post 'new' do
            required_attributes! [:name, :scenario]
            # check for the author
            author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
            # check for contributors
            contributors = params[:contributors].nil? ? [] : params[:contributors].collect { |c| User.find_by(username: c) }
            # get scenario
            scenario = Narra::Scenario.find(params[:scenario])
            # prepare params
            parameters = {name: params[:name], description: params[:description], author: author, contributors: contributors, scenario: scenario}
            # create library
            new_one(Library, Narra::API::Entities::Library, true, [:author], parameters) do |library|
              # check for the project if any
              project = Project.find_by(name: params[:project]) unless params[:project].nil?
              # authorize the owner
              unless project.nil?
                error_not_authorized! unless authorize([:author], project)
                # update projects if authorized
                project.libraries << library
              end
            end
          end

          desc 'Delete a specific library.'
          get ':id/delete' do
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author]).size > 0
              # set purged flag
              library.update_attributes(purged: true)
              # execute
              Narra::Core.purge_library(library)
              # present
              present_ok
            end
          end
        end
      end
    end
  end
end