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
      class ItemsV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :items do
          desc 'Create new item.'
          post 'new' do
            required_attributes! [:items]
            # authenticate
            authenticate!
            # authorization
            error_not_authorized! unless authorize([:author]).size > 0
            # items log
            items = []
            # check for items
            if params[:items].respond_to?('each')
              # iterate over all items
              params[:items].each do |item|
                # trying to get library
                library = Library.find(item[:library])
                # input metadata container
                metadata = []
                # check for metadata
                if !item[:metadata].nil? && !item[:metadata].empty?
                  # iterate through hash
                  item[:metadata].each do |key, value|
                    # store new source metadata
                    metadata << {name: key, value: value}
                  end
                end
                # parse connector
                connector = item[:connector].to_sym
                # check for options
                options = (item[:options].nil? ? {} : item[:options]).merge({metadata: metadata})
                # add new item
                items << Narra::Core.add_item(item[:url], current_user, library, connector, options)
              end
            end
            # present stats
            present_ok_generic(:items, items.collect { |item| item._id.to_s })
          end
        end
      end
    end
  end
end