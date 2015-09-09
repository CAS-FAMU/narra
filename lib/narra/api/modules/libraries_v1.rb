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

          desc 'Return a specific library.'
          get ':id' do
            return_one(Library, Narra::API::Entities::Library, :id, true, [:author])
          end

          desc 'Create new library.'
          post 'new' do
            required_attributes! [:name]
            # check for the author
            author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
            # check for contributors
            contributors = params[:contributors].nil? ? [] : params[:contributors].collect { |c| User.find_by(username: c) }
            # check for generators
            generators = params[:generators].nil? ? [] : params[:generators].select { |g| !Narra::Core.generator(g.to_sym).nil? }
            # prepare params
            parameters = {name: params[:name], description: params[:description], author: author, contributors: contributors, generators: generators}
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

          desc 'Update a specific library.'
          post ':id/update' do
            update_one(Library, Narra::API::Entities::Library, :id, true, [:author]) do |library|
              library.update_attributes(name: params[:name]) unless params[:name].nil? || library.name.equal?(params[:name])
              library.update_attributes(description: params[:description]) unless params[:description].nil? || library.description.equal?(params[:description])
              library.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || library.author.username.equal?(params[:author])
              library.shared = params[:shared] unless params[:shared].nil?
              # gather contributors if exist
              contributors = params[:contributors].nil? ? [] : params[:contributors].collect { |c| User.find_by(username: c) }
              # push them if changed
              library.update_attributes(contributors: contributors) unless contributors.sort == library.contributors.sort
              # gather generators if exist
              generators = params[:generators].nil? ? [] : params[:generators].select { |g| !Narra::Core.generator(g.to_sym).nil? }
              # push them if changed
              library.update_attributes(generators: generators) unless generators.sort == library.generators.sort
            end
          end

          desc 'Delete a specific library.'
          get ':id/delete' do
            return_one_custom(Library, :id, true, [:author]) do |library, authorized, public|
              # get authorized
              error_not_authorized! unless authorized
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