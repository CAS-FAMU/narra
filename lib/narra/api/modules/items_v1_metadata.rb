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
      class ItemsV1Metadata < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :items do

          desc 'Return all metadata for a specific item.'
          get ':id/metadata' do
            return_one_custom(Item, :id, [:admin, :author]) do |item|
              present_ok_generic_options('metadata', item.meta, {with: Narra::API::Entities::MetaItem, type: 'item'})
            end
          end

          desc 'Create a new metadata for a specific item.'
          post ':id/metadata/new' do
            required_attributes! [:meta, :value, :generator]
            return_one_custom(Item, :id, [:admin, :author]) do |item|
              # prepare marks
              marks = []
              # process marks
              if !params[:marks].nil? && !params[:marks].empty?
                params[:marks].each do |mark|
                  marks << { in: mark[:in], out: mark[:out] }
                end
              end
              # add metadata
              meta = item.add_meta(name: params[:meta], value: params[:value], generator: params[:generator].to_sym, marks: marks)
              # present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::MetaItem, type: 'item'})
            end
          end

          desc 'Return a specific metadata for a specific item.'
          get ':id/metadata/:meta' do
            required_attributes! [:generator]
            return_one_custom(Item, :id, [:admin, :author]) do |item|
              # get meta
              meta = item.get_meta(name: params[:meta], generator: params[:generator])
              # check existence
              error_not_found! if meta.nil?
              # otherwise present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::MetaItem, type: 'item'})
            end
          end

          desc 'Delete a specific metadata in a specific library.'
          get ':id/metadata/:meta/delete' do
            required_attributes! [:generator]
            return_one_custom(Item, :id, [:admin, :author]) do |item|
              # get meta
              meta = item.get_meta(name: params[:meta], generator: params[:generator])
              # check existence
              error_not_found! if meta.nil?
              # destroy
              meta.destroy
              # present
              present_ok
            end
          end

          desc 'Update a specific metadata for a specific item.'
          post ':id/metadata/:meta/update' do
            required_attributes! [:value, :generator]
            return_one_custom(Item, :id, [:admin, :author]) do |item|
              # prepare marks
              marks = []
              # process marks
              if !params[:marks].nil? && !params[:marks].empty?
                params[:marks].each do |mark|
                  marks << { in: mark[:in], out: mark[:out] }
                end
              end
              # update metadata
              meta = item.update_meta(name: params[:meta], value: params[:value], generator: params[:generator], marks: marks)
              # present
              present_ok_generic_options('metadata', meta, {with: Narra::API::Entities::MetaItem, type: 'item'})
            end
          end
        end
      end
    end
  end
end