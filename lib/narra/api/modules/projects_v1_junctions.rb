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
      class ProjectsV1Junctions < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :projects do

          desc 'Return project junctions based on synthesizer.'
          get ':name/junctions/:synthesizer' do
            return_one_custom(Project, :name, false, [:author]) do |project, authorized, public|
              # get authorized
              error_not_authorized! unless authorized || public
              # present
              present_ok(project.junctions.where(synthesizer: params[:synthesizer].to_sym).limit(params[:limit]), Junction, Narra::API::Entities::Junction)
            end
          end

          desc 'Return junction items based on synthesizer.'
          get ':name/junctions/:synthesizer/items' do
            return_one_custom(Project, :name, false, [:author]) do |project, authorized, public|
              # get authorized
              error_not_authorized! unless authorized || public
              # present
              present_ok(project.junctions.where(synthesizer: params[:synthesizer].to_sym).collect { |junction| junction.items}.flatten, Item, Narra::API::Entities::Item)
            end
          end
        end
      end
    end
  end
end