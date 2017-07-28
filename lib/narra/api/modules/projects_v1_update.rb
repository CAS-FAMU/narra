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
# Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
#

require 'json'

module Narra
  module API
    module Modules
      class ProjectsV1Sequences < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes
        helpers Narra::API::Helpers::Array

        resource :projects do

          desc 'Update a specific project.'
          post ':name/update' do
            update_one(Project, Narra::API::Entities::Project, :name, true, [:author]) do |project|
              # change name if there is a change
              project.update_attributes(name: params[:new_name]) unless params[:new_name].nil? || project.name.equal?(params[:new_name])
              project.update_attributes(title: params[:title]) unless params[:title].nil? || project.title.equal?(params[:title])
              project.update_attributes(description: params[:description]) unless params[:description].nil? || project.description.equal?(params[:description])
              project.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || project.author.username.equal?(params[:author])
              project.update_attributes(scenario: Scenario.find(params[:scenario])) unless params[:scenario].nil? || project.scenario._id.equal?(params[:scenario])
              project.public = params[:public] unless params[:public].nil?
              # update contributors if exist
              update_array(project.contributors, params[:contributors].collect { |c| User.find_by(username: c) }) unless params[:contributors].nil?
              # update libraries if exist
              update_array(project.libraries, params[:libraries].collect { |l| Library.find(l) }) unless params[:libraries].nil?
            end
          end
        end
      end
    end
  end
end