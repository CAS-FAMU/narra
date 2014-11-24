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
            return_many(Library, Narra::API::Entities::Library, [:admin, :author])
          end

          desc 'Create new library.'
          post 'new' do
            required_attributes! [:name, :title]
            new_one(Library, Narra::API::Entities::Library, :name, {name: params[:name], title: params[:title], description: params[:description], owner: current_user}, [:admin, :author]) do |library|
              # check for the project if any
              project = Project.find_by(name: params[:project]) unless params[:project].nil?
              # authorize the owner
              if !project.nil?
                authorize!([:author], project)
                # update projects if authorized
                library.projects << project
              end
            end
          end

          desc 'Return a specific library.'
          get ':name' do
            return_one(Library, Narra::API::Entities::Library, :name, [:admin, :author])
          end

          desc 'Update a specific library.'
          post ':name/update' do
            update_one(Library, Narra::API::Entities::Library, :name, [:admin, :author]) do |library|
              library.update_attributes(title: params[:title]) unless params[:title].nil?
              library.update_attributes(description: params[:description]) unless params[:description].nil?
            end
          end

          desc 'Delete a specific library.'
          get ':name/delete' do
            delete_one(Library, :name, [:admin, :author])
          end

          desc 'Return a specific library items.'
          get ':name/items' do
            auth! [:admin, :author]
            # get user
            library = Library.find_by(name: params[:name])
            # present or not found
            if (library.nil?)
              error_not_found!
            else
              present_ok(library.items.limit(params[:limit]), Item, Narra::API::Entities::Item)
            end
          end
        end
      end
    end
  end
end