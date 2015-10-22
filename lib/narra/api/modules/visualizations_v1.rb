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
        helpers Narra::API::Helpers::Array

        resource :visualizations do

          desc 'Return all visualizations.'
          get do
            return_many(Narra::Visualization, Narra::API::Entities::Visualization, false, [:author])
          end

          desc 'Return a specific visualization.'
          get ':id' do
            return_one(Narra::Visualization, Narra::API::Entities::Visualization, :id, false, [:author])
          end

          desc 'Add new visualization.'
          post 'new' do
            required_attributes! [:name, :type]
            # check for the author
            author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
            # check for the options
            options =params[:options].nil? ? {} : eval(params[:options])
            # prepare params
            parameters = {name: params[:name], type: params[:type].to_sym, description: params[:description], author: author, options: options}
            # create new project
            new_one(Narra::Visualization, Narra::API::Entities::Visualization, true, [:author], parameters) do |visualization|
              # update script file
              if params[:file]
                visualization.script = params[:file][:tempfile]
              else
                case params[:type].to_sym
                  when :processing
                    template = "#{params[:type].to_s}.pde"
                  when :p5js
                    template = "#{params[:type].to_s}.js"
                end
                # update script
                visualization.script = File.new("#{Rails.root}/lib/templates/visualizations/#{template}")
              end
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
              visualization.update_attributes(options: eval(params[:options])) unless params[:options].nil? || visualization.options.equal?(eval(params[:options]))
              visualization.public = params[:public] unless params[:public].nil?
              # update contributors if exist
              update_array(visualization.contributors, JSON.parse(params[:contributors]).collect { |c| User.find_by(username: c) }) unless params[:contributors].nil?
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