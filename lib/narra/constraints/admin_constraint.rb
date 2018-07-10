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
# Authors: Michal Mocnak <michal@marigan.net>
#

module Narra
  module Constraints
    class AdminConstraint

      def self.matches?(request)
        # check for token presence
        return false if request.params[:token].nil? && request.session[:token].nil?

        begin
          # set token to session
          request.session[:token] = request.params[:token] unless request.params[:token].nil?

          # decode token
          decoded_token = ::JWT.decode request.session[:token], Narra::JWT::RSA_PUBLIC, true, { :algorithm => 'RS256' }

          # get uid
          uid = decoded_token[0]['uid']

          # get identity for token
          identity = Narra::Identity.where(uid: uid).first

          # signout in case non existing identity
          raise if identity.nil?

          # get user from token
          return identity.user.is?([:admin])
        rescue
          return false
        end
      end
    end
  end
end