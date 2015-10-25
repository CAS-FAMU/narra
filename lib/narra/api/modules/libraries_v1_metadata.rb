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
      class LibrariesV1Metadata < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :libraries do

          desc 'Return all metadata for a specific library.'
          get ':id/metadata' do
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author, :contributor, :parent_author, :parent_contributor]).size > 0
              # present
              present_ok_generic_options('metadata', library.meta, {with: Narra::API::Entities::Meta, type: 'library'})
            end
          end

          desc 'Create a new metadata for a specific library.'
          post ':id/metadata/new' do
            required_attributes! [:meta, :value]
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author, :contributor]).size > 0
              # check the author field
              author = params[:author].nil? ? current_user : Narra::User.find_by(username: params[:author])
              # add metadata
              meta = library.add_meta(name: params[:meta], value: params[:value], author: author)
              # present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::Meta, type: 'library'})
            end
          end

          desc 'Return a specific metadata for a specific library.'
          get ':id/metadata/:meta' do
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author, :contributor, :parent_author, :parent_contributor]).size > 0
              # get meta
              meta = library.get_meta(name: params[:meta])
              # check existence
              error_not_found! if meta.nil?
              # otherwise present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::Meta, type: 'library'})
            end
          end

          desc 'Delete a specific metadata in a specific library.'
          get ':id/metadata/:meta/delete' do
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author, :contributor]).size > 0
              # get meta
              meta = library.get_meta(name: params[:meta])
              # check existence
              error_not_found! if meta.nil?
              # destroy
              meta.destroy
              # present
              present_ok
            end
          end

          desc 'Update a specific metadata for a specific library.'
          post ':id/metadata/:meta/update' do
            required_attributes! [:value]
            return_one_custom(Library, :id, true, [:author]) do |library, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author, :contributor]).size > 0
              # check the author field
              author = params[:author].nil? ? current_user : Narra::User.find_by(username: params[:author])
              # update metadata
              meta = library.update_meta(name: params[:meta], value: params[:value], author: author)
              # present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::Meta, type: 'library'})
            end
          end
        end
      end
    end
  end
end