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
      class LibrariesV1Items < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :libraries do

          desc 'Return a specific library items.'
          get ':id/items' do
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless public || (roles & [:admin, :author, :contributor, :parent_author, :parent_contributor]).size > 0
              # present
              present_ok(library.items.limit(params[:limit]), Item, Narra::API::Entities::Item)
            end
          end
          
          desc 'Return all values for specific meta field.'
          get ':id/items/metadata/:name' do
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless public || (roles & [:admin, :author, :contributor, :parent_author, :parent_contributor]).size > 0
              # get meta values
              metas = library.items.collect { |item| item.get_meta(name: params[:name])}
              values = metas.select { |meta| !meta.nil? }.collect { |meta| meta.value }
              # present
              present_ok_generic(:values, values)
            end
          end
        end
      end
    end
  end
end