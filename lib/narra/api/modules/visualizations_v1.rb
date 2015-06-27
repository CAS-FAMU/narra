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
      class VisualizationsV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :visualizations do

          desc 'Return all visualizations.'
          get do
            return_many(Narra::Visualization, Narra::API::Entities::Visualization, false, [:author])
          end

          desc 'Return a specific visualization.'
          get ':id' do
            return_one(Narra::Visualization, Narra::API::Entities::Visualization, :id, true, [:author])
          end

          desc 'Add new visualization.'
          post 'new' do
            required_attributes! [:name, :type, :file]
            # check for the author
            author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
            # prepare params
            parameters = {name: params[:name], type: params[:type].to_sym, description: params[:description], author: author}
            # create new project
            new_one(Narra::Visualization, Narra::API::Entities::Visualization, true, [:author], parameters) do |visualization|
              # update script file
              visualization.script = params[:file][:tempfile]
              # save it
              visualization.save
            end
          end

          desc 'Update a specific visualization.'
          post ':id/update' do
            update_one(Visualization, Narra::API::Entities::Visualization, :id, true, [:author]) do |visualization|
              # change name if there is a change
              visualization.update_attributes(name: params[:name]) unless params[:name].nil? || visualization.name.equal?(params[:name])
              visualization.update_attributes(description: params[:description]) unless params[:description].nil? || visualization.description.equal?(params[:description])
              visualization.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || visualization.author.username.equal?(params[:author])
              visualization.public = params[:public] unless params[:public].nil?
              # replace file if changed
              if params[:file]
                # update script file
                visualization.script = params[:file][:tempfile]
                # save it
                visualization.save
              end
            end
          end

          desc 'Delete a specific visualization.'
          get ':id/delete' do
            delete_one(Narra::Visualization, :id, true, [:author])
          end
        end
      end
    end
  end
end