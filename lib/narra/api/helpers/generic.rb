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
# Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
#

module Narra
  module API
    module Helpers
      module Generic

        # generic auth process
        def auth!(authorization = [], authentication = true)
          authenticate! if authentication
          authorize!(authorization) unless authorization.empty?
        end

        # generic method for returning of the specific object based on the owner
        def return_many(model, entity = nil, authorization = [], authentication = true)
          auth!(authorization, authentication)
          # get items
          items = params[:author].nil? ? model.limit(params[:limit]) : model.where(author: ::User.find(params[:owner])).limit(params[:limit])
          # present
          present_ok(items, model, entity)
        end

        # Generic method for returning of the specific object based on the owner
        def return_one(model, entity, key, authorization = [], authentication = true)
          return_one_custom(model, key, authorization, authentication) do |object|
            # present
            present_ok(object, model, entity, 'detail')
          end
        end

        def return_one_custom(model, key, authorization = [], authentication = true)
          auth!(authorization, authentication)
          # get project
          object = model.find_by(key => params[key])
          # present or not found
          if (object.nil?)
            error_not_found!
          else
            # authorize the owner
            authorize!([:author], object) unless authorization.empty?
            # custom action
            yield object if block_given?
          end
        end

        def new_one(model, entity, key, parameters, authorization = [], authentication = true)
          auth!(authorization, authentication)
          # get object
          object = model.find_by(key => params[key])
          # present or not found
          if (object.nil?)
            # create new object
            object = model.new(parameters)
            # object specified code
            yield object if block_given?
            # save
            object.save!
            # probe
            object.probe if object.is_a? Narra::Tools::Probeable
            # present
            present_ok(object, model, entity, 'detail')
          else
            error_already_exists!
          end
        end

        def new_one_custom(model, entity, authorization = [], authentication = true)
          auth!(authorization, authentication)
            # object specified code
            object = yield if block_given?
          if not object.nil?
            # probe
            object.probe if object.is_a? Narra::Tools::Probeable
            # present
            present_ok(object, model, entity, 'detail')
          else
            error_unknown!
          end
        end

        def update_one(model, entity, key, authorization = [], authentication = true)
          auth!(authorization, authentication)
          # get object
          object = model.find_by(key => params[key])
          # present or not found
          if (object.nil?)
            error_not_found!
          else
            # authorize the owner
            authorize!([:author], object) unless authorization.empty?
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
        def delete_one(model, key, authorization = [], authentication = true)
          auth!(authorization, authentication)
          # get object
          object = model.find_by(key => params[key])
          # present or not found
          if (object.nil?)
            error_not_found!
          else
            # authorize the owner
            authorize!([:author], object) unless authorization.empty?
            # destroy
            object.destroy
            # present
            present_ok
          end
        end
      end
    end
  end
end