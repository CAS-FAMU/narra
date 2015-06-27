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
    module Helpers
      module User

        def authenticate!
          error_not_authenticated! unless current_user
        end

        def authorize(roles, object = nil)
          # do not authorize when public or no roles
          return false if current_user.nil? || roles.empty?

          # resolve
          if object.nil?
            current_user.is?([:admin]) || current_user.is?(roles)
          else
            # if the object supports authors or contributors resolve
            is_author?(object)
          end
        end

        def is_author?(object)
          # admin is author
          return true if is_admin?
          # check if the object is an item
          object = object.library if object.is_a?(Narra::Item)
          # process permissions
          if object.has_attribute?('author_id')
            # resolve permissions
            object.author_id == current_user._id
          elsif object.has_attribute?('contributor_ids')
            object.author_id == object.contributor_ids.include?(current_user._id)
          else
            # there is no support for authorship
            return false
          end
        end

        def is_admin?
          return true if current_user.is?([:admin])
        end

        def current_user
          # check for token presence
          return nil if params[:token].nil? && env['rack.session'][:token].nil?

          begin
            # set token to session
            env['rack.session'][:token] = params[:token] unless params[:token].nil?

            # get uid
            uid = Base64::urlsafe_decode64(env['rack.session'][:token])

            # get identity for token
            identity = Identity.where(uid: uid).first

            # signout in case non existing identity
            raise && signout if identity.nil?

            # return user
            @current_user ||= identity.user
          rescue
            return nil
          end
        end

        def signout
          # clean current user
          @current_user = nil
          # delete session token
          env['rack.session'][:token] = nil
        end
      end
    end
  end
end
