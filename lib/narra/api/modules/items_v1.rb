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
      class ItemsV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :items do

          desc 'Return all items.'
          get do
            return_many(Item, Narra::API::Entities::Item, true, [:admin])
          end

          desc 'Return a specific item.'
          get ':id' do
            return_one(Item, Narra::API::Entities::Item, :id, true, [:author])
          end

          desc 'Check new item.'
          post 'check' do
            required_attributes! [:url]
            # parse url to get appropriate object
            object = Narra::Core.check_item(params[:url])
            # if nil return error
            error_not_found! if object.nil?
            # otherwise return proper item proxy
            present_ok_generic(:item, present({name: object.name, url: object.source_url, type: object.type, connector: object.class.identifier, thumbnail: object.thumbnail_url}))
          end

          desc 'Create new item.'
          post 'new' do
            required_attributes! [:url, :library, :connector]
            new_one(Item, Narra::API::Entities::Item, true, [:author]) do
              # trying to get library
              library = Library.find(params[:library])
              # check the author field
              author = params[:author].nil? ? current_user.name : params[:author]
              # input metadata container
              metadata = []
              # check for metadata
              if !params[:metadata].nil? && !params[:metadata].empty?
                # iterate through hash
                params[:metadata].each do |key, value|
                  # store new source metadata
                  metadata << {name: key, value: value}
                end
              end
              # parse connector
              connector = params[:connector].to_sym
              # check for options
              options = (params[:options].nil? ? {} : params[:options]).merge({metadata: metadata})
              # add new item
              Narra::Core.add_item(params[:url], author, current_user, library, connector, options)
            end
          end

          desc 'Delete a specific item.'
          get ':id/delete' do
            delete_one(Item, :id, true, [:author])
          end
        end
      end
    end
  end
end