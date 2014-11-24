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
      class Authentication < Narra::API::Modules::Generic

        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Present

        resource :auth do
          post '/:provider/callback' do
            auth = request.env['omniauth.auth']

            unless @auth = Narra::Identity.find_from_hash(auth)
              # Create a new user or add an auth to existing user, depending on
              # whether there is already a user signed in.
              @auth = Narra::Identity.create_from_hash(auth, Narra::User.where(email: auth['info']['email']).first)
            end

            # get token
            @token = CGI::escape(Base64.urlsafe_encode64(auth['uid']))

            # get back to origin path or return token
            if request.env['omniauth.origin']
              redirect request.env['omniauth.origin'] + '?token=' + @token, :permanent => true
            end

            # return token in json when request is not from browser
            present_ok_generic(:token, @token)
          end
        end
      end
    end
  end
end