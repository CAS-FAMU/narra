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

          desc 'Return all projects.'
          get do
            return_many(Project, Narra::API::Entities::Project, [], false)
          end

          desc 'Return a specific project.'
          get ':name' do
            return_one(Project, Narra::API::Entities::Project, :name, [:admin, :author])
          end

          desc 'Create new project.'
          post 'new' do
            required_attributes! [:name, :title]
            # check for the author
            author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
            # check for contributors
            contributors = params[:contributors].nil? ? [] : params[:contributors].collect { |c| User.find_by(username: c) }
            # check for generators
            synthesizers = params[:synthesizers].nil? ? [] : params[:synthesizers].select { |s| !Narra::Core.synthesizer(s.to_sym).nil? }
            # create new project
            new_one(Project, Narra::API::Entities::Project, :name, {name: params[:name], title: params[:title], description: params[:description], author: author, contributors: contributors, synthesizers: synthesizers}, [:admin, :author])
          end

          desc 'Update a specific project.'
          post ':name/update' do
            update_one(Project, Narra::API::Entities::Project, :name, [:admin, :author]) do |project|
              # change name if there is a change
              project.update_attributes(name: params[:new_name]) unless params[:new_name].nil? || project.name.equal?(params[:new_name])
              project.update_attributes(title: params[:title]) unless params[:title].nil? || project.title.equal?(params[:title])
              project.update_attributes(description: params[:description]) unless params[:description].nil? || project.description.equal?(params[:description])
              project.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || project.author.username.equal?(params[:author])
              # gather contributors if exist
              contributors = params[:contributors].nil? ? [] : params[:contributors].collect { |c| User.find_by(username: c) }
              # push them if changed
              project.update_attributes(contributors: contributors) unless contributors.sort == project.contributors.sort
              # gather generators if exist
              synthesizers = params[:synthesizers].nil? ? [] : params[:synthesizers].select { |s| !Narra::Core.synthesizer(s.to_sym).nil? }
              # push them if changed
              project.update_attributes(synthesizers: generators) unless synthesizers.sort == projects.synthesizers.sort
            end
          end

          desc 'Delete a specific project.'
          get ':name/delete' do
            delete_one(Project, :name, [:admin, :author])
          end
        end
      end
    end
  end
end