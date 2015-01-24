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

module Narra
  module API
    module Modules
      class ProjectsV1Items < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :projects do

          desc 'Return project items.'
          get ':name/items' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              present_ok(project.items.limit(params[:limit]), Item, Narra::API::Entities::Item)
            end
          end

          desc 'Return project item.'
          get ':name/items/:item' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # Get item
              items = Item.where(name: params[:item]).any_in(library_id: project.library_ids)
              # Check for the first and the last
              items |= [project.items.first] if params[:item].equal?('first')
              items |= [project.items.last] if params[:item].equal?('last')
              # Check if the item is part of the project
              if items.empty?
                error_not_found!
              else
                present_ok(items.first, Item, Narra::API::Entities::Item, 'detail', project: project)
              end
            end
          end
        end
      end
    end
  end
end