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
    module Entities
      class Item < Grape::Entity

        expose :id do |model, options|
          model._id.to_s
        end

        expose :name, :url, :type

        expose :prepared do |model, options|
          model.prepared?
        end

        expose :owner do |model, options|
          { username: model.owner.username, name: model.owner.name}
        end

        expose :library, format_with: :library, if: {type: :detail_item}

        format_with :library do |library|
          {id: library._id.to_s, name: library.name}
        end

        expose :thumbnails, if: lambda { |model, options| !model.url_thumbnails.nil? && !model.url_thumbnails.empty? } do |model, options|
          model.url_thumbnails
        end

        expose :video_proxy_hq, if: lambda { |model, options| model.type == :video && model.prepared? } do |model, options|
          model.url_video_proxy_hq
        end

        expose :video_proxy_lq, if: lambda { |model, options| model.type == :video && model.prepared? } do |model, options|
          model.url_video_proxy_lq
        end

        expose :image_proxy_hq, if: lambda { |model, options| model.type == :image && model.prepared? } do |model, options|
          model.url_image_proxy_hq
        end

        expose :image_proxy_lq, if: lambda { |model, options| model.type == :image && model.prepared? } do |model, options|
          model.url_image_proxy_lq
        end

        expose :meta, as: :metadata, using: Narra::API::Entities::Meta, if: {type: :detail_item} do |item, options|
          # get scoped metadata for item
          options[:project].nil? ? item.meta : Narra::Meta.where(item: item).generators(options[:project].generators)
        end
      end
    end
  end
end