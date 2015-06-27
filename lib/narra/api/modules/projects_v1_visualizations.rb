#
# Copyright (C) 2015 CAS / FAMU
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
# Authors: Michal Mocnak <michal@marigan.net>
#

module Narra
  module API
    module Modules
      class ProjectsV1Visualizations < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :projects do
          
          desc 'Add or remove visualizations'
          post ':name/visualizations/:action' do
            required_attributes! [:visualizations]
            update_one(Project, Narra::API::Entities::Project, :name, true, [:author]) do |project|
              params[:visualizations].each do |visualization|
                if params[:action] == 'add'
                  project.visualizations << Narra::Visualization.find(visualization)
                elsif params[:action] == 'remove'
                  project.visualizations.delete(Narra::Visualization.find(visualization))
                end
              end
            end
          end
        end
      end
    end
  end
end