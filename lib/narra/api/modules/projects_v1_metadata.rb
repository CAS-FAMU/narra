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
      class ProjectsV1Metadata < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :projects do

          desc 'Return all metadata for a specific project.'
          get ':name/metadata' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              present_ok_generic_options('metadata', project.meta, {with: Narra::API::Entities::MetaProject, type: 'project'})
            end
          end

          desc 'Create a new metadata for a specific project.'
          post ':name/metadata/new' do
            required_attributes! [:meta, :value]
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # add metadata
              meta = project.add_meta(name: params[:meta], value: params[:value])
              # present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::MetaProject, type: 'project'})
            end
          end

          desc 'Return a specific metadata for a specific project.'
          get ':name/metadata/:meta' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # get meta
              meta = project.get_meta(name: params[:meta])
              # check existence
              error_not_found! if meta.nil?
              # otherwise present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::MetaProject, type: 'project'})
            end
          end

          desc 'Update a specific metadata for a specific project.'
          post ':name/metadata/:meta/update' do
            required_attributes! [:value]
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # add metadata
              meta = project.update_meta(name: params[:meta], value: params[:value])
              # present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::MetaProject, type: 'project'})
            end
          end
        end
      end
    end
  end
end