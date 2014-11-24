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
      class ProjectsV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :projects do

          desc "Return all projects."
          get do
            return_many(Project, Narra::API::Entities::Project, [], false)
          end

          desc "Create new project."
          params do
            requires :name, type: String, desc: "Name of new project."
            requires :title, type: String, desc: "Title of new project."
          end
          post 'new' do
            required_attributes! [:name, :title]
            new_one(Project, Narra::API::Entities::Project, :name, {name: params[:name], title: params[:title], description: params[:description], owner: current_user}, [:admin, :author])
          end

          desc "Return a specific project."
          get ':name' do
            return_one(Project, Narra::API::Entities::Project, :name, [:admin, :author])
          end

          desc "Update a specific project."
          post ':name/update' do
            update_one(Project, Narra::API::Entities::Project, :name, [:admin, :author]) do |project|
              project.update_attributes(title: params[:title]) unless params[:title].nil?
              project.update_attributes(description: params[:description]) unless params[:description].nil?
            end
          end

          desc "Delete a specific project."
          get ':name/delete' do
            delete_one(Project, :name, [:admin, :author])
          end

          desc "Add or remove libraries"
          post ':name/libraries/:action' do
            required_attributes! [:libraries]
            update_one(Project, Narra::API::Entities::Project, :name, [:admin, :author]) do |project|
              params[:libraries].each do |library|
                if params[:action] == 'add'
                  project.libraries << Library.find_by(name: library)
                elsif params[:action] == 'remove'
                  project.libraries.delete(Library.find_by(name: library))
                end
              end
            end
          end

          desc "Return project's items."
          get ':name/items' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              present_ok(project.items.limit(params[:limit]), Item, Narra::API::Entities::Item)
            end
          end

          desc "Return project's item."
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

          desc "Return project's sequences."
          get ':name/sequences' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              present_ok(project.sequences.limit(params[:limit]), Sequence, Narra::API::Entities::Sequence)
            end
          end

          desc "Return project's sequence."
          get ':name/sequences/:sequence' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # Get item
              sequences = project.sequences.where(id: params[:sequence])
              # Check if the item is part of the project
              if sequences.empty?
                error_not_found!
              else
                present_ok(sequences.first, Sequence, Narra::API::Entities::Sequence, 'detail')
              end
            end
          end
        end
      end
    end
  end
end