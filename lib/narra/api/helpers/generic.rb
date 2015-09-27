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

module Narra
  module API
    module Helpers
      module Generic

        # generic method for returning of the specific object based on the owner
        def return_many(model, entity, authentication, authorization = [])
          authenticate! if authentication
          # check for user and authorize
          roles = authorize(authorization)
          # check for public
          public = model.method_defined?(:is_public?)
          # get items
          if roles.size > 0
            if roles.include?(:admin)
              objects = model.limit(params[:limit])
            elsif roles.include?(:user)
              objects = model.all.select { |o| (authorize(authorization, o) & [:author, :contributor, :parent_author, :parent_contributor]).size > 0 }
            elsif public
              objects = model.all.select { |o| (authorize(authorization, o) & [:author, :contributor, :parent_author, :parent_contributor]).size > 0 || o.is_public? }
            end
          else
            if public
              objects = model.all.select { |o| o.is_public? }
            else
              error_not_authorized!
            end
          end
          # present
          present_ok(objects, model, entity)
        end

        # Generic method for returning of the specific object based on the owner
        def return_one(model, entity, key, authentication, authorization = [])
          return_one_custom(model, key, authentication, authorization) do |object, roles, public|
            # resolve
            if (roles & [:admin, :author, :contributor, :parent_author, :parent_contributor]).size > 0 || public
              present_ok(object, model, entity, 'detail')
            else
              error_not_authorized!
            end
          end
        end

        def return_one_custom(model, key, authentication, authorization = [])
          authenticate! if authentication
          # get object
          object = model.find_by(key => params[key])
          # present or not found
          if object.nil?
            error_not_found!
          else
            # is public
            public = model.method_defined?(:is_public?) && object.is_public?
            # custom action
            yield object, authorize(authorization, object), public if block_given?
          end
        end

        def new_one(model, entity, authentication, authorization = [], parameters = {})
          authenticate! if authentication
          # authorization
          error_not_authorized! unless authorize(authorization).size > 0
          # object specified code
          if parameters.empty?
            object = yield if block_given?
          else
            # create object
            object = model.create(parameters)
            # block
            yield object if block_given?
            # save
            object.save!
          end
          # check for
          unless object.nil?
            # probe
            object.probe if object.is_a? Narra::Tools::Probeable
            # present
            present_ok(object, model, entity, 'detail')
          else
            error_unknown!
          end
        end

        def update_one(model, entity, key, authentication, authorization = [])
          return_one_custom(model, key, authentication, authorization) do |object, roles, public|
            # authorization
            error_not_authorized! unless (roles & [:admin, :author, :contributor]).size > 0
            # update custom code
            yield object if block_given?
            # save
            object.save!
            # probe
            object.probe if object.is_a? Narra::Tools::Probeable
            # present
            present_ok(object, model, entity, 'detail')
          end
        end

        # Generic method for deleting of the specific object based on the owner
        def delete_one(model, key, authentication, authorization = [])
          return_one_custom(model, key, authentication, authorization) do |object, roles, public|
            # authorization
            error_not_authorized! unless (roles & [:admin, :author]).size > 0
            # update custom code
            yield object if block_given?
            # save
            object.destroy
            # present
            present_ok
          end
        end
      end
    end
  end
end