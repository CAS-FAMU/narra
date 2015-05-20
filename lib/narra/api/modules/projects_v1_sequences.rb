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

        resource :projects do

          desc 'Return project sequences.'
          get ':name/sequences' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              present_ok(project.sequences.limit(params[:limit]), Sequence, Narra::API::Entities::Sequence)
            end
          end

          desc 'Add new sequence.'
          post ':name/sequences/new' do
            required_attributes! [:type, :title, :file, :params]
            # Resolve project and add sequence
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # check for the author
              author = params[:author].nil? ? current_user : User.find_by(username: params[:author])
              # get file content
              content = params[:file][:tempfile].read
              # prepare sequence hash
              sequence = {sequence_type: params[:type].to_sym, sequence_name: params[:title], sequence_content: content}.merge(Hash[JSON.parse(params[:params]).map{ |k, v| [k.to_sym, v] }])
              # add sequence
              Narra::Core.add_sequence(project, author, sequence)
              # present
              present_ok
            end
          end

          desc 'Return project sequence.'
          get ':name/sequences/:sequence' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # Get item
              sequence = project.sequences.find(params[:sequence])
              # Check if the item is part of the project
              if sequence.nil?
                error_not_found!
              else
                present_ok(sequence, Sequence, Narra::API::Entities::Sequence, 'detail')
              end
            end
          end

          desc 'Delete a specific sequence.'
          get ':name/sequences/:sequence/delete' do
            return_one_custom(Project, :name, [:admin, :author]) do |project|
              # Get item
              sequence = project.sequences.find(params[:sequence])
              # Check if the item is part of the project
              if sequence.nil?
                error_not_found!
              else
                # destroy
                sequence.destroy
                # present
                present_ok
              end
            end
          end
        end
      end
    end
  end
end