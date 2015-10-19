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
        helpers Narra::API::Helpers::Array

        resource :libraries do

          desc 'Update a specific library.'
          post ':id/update' do
            update_one(Library, Narra::API::Entities::Library, :id, true, [:author]) do |library|
              library.update_attributes(name: params[:name]) unless params[:name].nil? || library.name.equal?(params[:name])
              library.update_attributes(description: params[:description]) unless params[:description].nil? || library.description.equal?(params[:description])
              library.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || library.author.username.equal?(params[:author])
              library.shared = params[:shared] unless params[:shared].nil?
              # update contributors if exist
              update_array(library.contributors, params[:contributors].collect { |c| User.find_by(username: c) }) unless params[:contributors].nil?
              # gather generators if exist
              unless params[:generators].nil?
                generators = params[:generators].select { |g| !Narra::Core.generator(g[:identifier].to_sym).nil? }
                # push them if changed
                library.update_attributes(generators: generators) unless generators.sort == library.generators.sort
              end
            end
          end
        end
      end
    end
  end
end