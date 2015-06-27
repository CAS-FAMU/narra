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
      class UsersV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :users do

          desc "Return users."
          get do
            return_many(User, Narra::API::Entities::User, true, [:author])
          end

          desc "Return logged user in the current session."
          get 'me' do
            authenticate!
            # present
            present_ok(current_user, User, Narra::API::Entities::User)
          end

          desc "Signout logged user in the current session."
          get 'me/signout' do
            authenticate!
            # signout
            signout
            # return
            present_ok
          end

          desc "Return roles."
          get 'roles' do
            authenticate!
            # get authorized
            error_not_authorized! unless authorize([:author])
            # present
            present_ok_generic(:roles, present(User.all_roles))
          end

          desc "Return a specific user."
          get ':username' do
            return_one(User, Narra::API::Entities::User, :username, true, [:admin])
          end

          desc "Delete a specific user."
          get ':username/delete' do
            delete_one(User, :username, true, [:admin])
          end

          desc "Update a user."
          post ':username/update' do
            required_attributes! [:roles]
            update_one(User, Narra::API::Entities::User, :username, true, [:author]) do |user|
              # gather new roles
              new_roles = params[:roles].collect { |role| role.to_sym }
              if user.roles.sort != new_roles.sort
                # authorize for admin to change roles
                error_not_authorized! unless authorize([:admin])
                # change roles
                user.update_attributes(roles: new_roles)
              end
              # change email if there is a change
              user.update_attributes(email: params[:email]) unless params[:email].nil? || user.email.equal?(params[:email])
              # change username if there is a change
              user.update_attributes(username: params[:new_username]) unless params[:new_username].nil? || user.username.equal?(params[:new_username])
            end
          end
        end
      end
    end
  end
end