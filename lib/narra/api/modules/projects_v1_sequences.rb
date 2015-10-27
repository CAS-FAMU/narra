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
            return_one_custom(Project, :name, false, [:author]) do |project, roles, public|
              # if not authenticated or nto contributor or author return just public otherwise return all
              if (roles & [:admin, :author, :contributor]).size > 0
                present_ok(project.sequences.limit(params[:limit]), Sequence, Narra::API::Entities::Sequence)
              else
                if public
                  present_ok(project.sequences.select { |s| s.is_public? }, Sequence, Narra::API::Entities::Sequence)
                else
                  error_not_authorized!
                end
              end
            end
          end

          desc 'Return project sequence.'
          get ':name/sequences/:id' do
            return_one(Narra::Sequence, Narra::API::Entities::Sequence, :id, false, [:author])
          end

          desc 'Add new sequence.'
          post ':name/sequences/new' do
            required_attributes! [:type, :title, :fps]
            # Resolve project and add sequence
            return_one_custom(Project, :name, true, [:author]) do |project, roles, public|
              # get authorized
              error_not_authorized! unless (roles & [:admin, :author, :contributor]).size > 0
              # get file content
              if params[:file]
                content = params[:file][:tempfile].read
              end
              # prepare sequence hash
              sequence = {sequence_type: params[:type].to_sym, sequence_name: params[:title], sequence_content: content, sequence_fps: params[:fps], metadata: params[:metadata]}
              # add sequence
              Narra::Core.add_sequence(project, current_user, sequence)
              # present
              present_ok
            end
          end

          desc 'Update a specific visualization.'
          post ':name/sequences/:id/update' do
            update_one(Narra::Sequence, Narra::API::Entities::Sequence, :id, true, [:author]) do |sequence|
              # change name if there is a change
              sequence.update_attributes(name: params[:title]) unless params[:title].nil? || sequence.name.equal?(params[:title])
              sequence.update_attributes(description: params[:description]) unless params[:description].nil? || sequence.description.equal?(params[:description])
              sequence.update_attributes(author: User.find_by(username: params[:author])) unless params[:author].nil? || sequence.author.username.equal?(params[:author])
              sequence.public = params[:public] unless params[:public].nil?
              # update contributors if exist
              update_array(sequence.contributors, params[:contributors].collect { |c| User.find_by(username: c) }) unless params[:contributors].nil?
            end
          end

          desc 'Delete a specific visualization.'
          get ':name/sequences/:id/delete' do
            delete_one(Narra::Sequence, :id, true, [:author])
          end
        end
      end
    end
  end
end