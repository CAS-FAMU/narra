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

        expose :master, if: lambda { |model, options| model.master? } do |item|
          item.master?
        end

        expose :sequence, if: lambda { |model, options| options[:type] == :detail_item && model.master? } do |item|
          { id: item.sequence._id.to_s, name: item.sequence.name }
        end

        expose :purged, if: lambda { |model, options| model.library.purged } do |item|
          item.library.purged
        end

        expose :library, format_with: :library, if: {type: :detail_item}

        format_with :library do |library|
          {
              id: library._id.to_s,
              name: library.name,
              author: { username: library.author.username, name: library.author.name },
              contributors: library.contributors.collect { |user| {username: user.username, name: user.name} }
          }
        end

        expose :keywords, if: lambda { |model, options| !model.get_meta(name: 'keywords').nil? } do |item|
          # keywords
          metadata = item.get_meta(name: 'keywords')
          # return the right one
          value = metadata.respond_to?('each') ? metadata.first.value : metadata.value
          # get values and return first 5
          value.split(',').first(5).join(', ')
        end

        include Narra::API::Entities::Thumbnails

        expose :video_proxy_hq, if: lambda { |model, options| (options[:type] == :detail_item || options[:type] == :public_item) && model.type == :video && model.prepared? } do |model, options|
          model.video.url
        end

        expose :video_proxy_lq, if: lambda { |model, options| (options[:type] == :detail_item || options[:type] == :public_item) && model.type == :video && model.prepared? } do |model, options|
          model.video.lq.url
        end

        expose :image_proxy_hq, if: lambda { |model, options| (options[:type] == :detail_item || options[:type] == :public_item) && model.type == :image && model.prepared? } do |model, options|
          model.image.url
        end

        expose :image_proxy_lq, if: lambda { |model, options| (options[:type] == :detail_item || options[:type] == :public_item) && model.type == :image && model.prepared? } do |model, options|
          model.image.lq.url
        end

        expose :audio_proxy, if: lambda { |model, options| (options[:type] == :detail_item || options[:type] == :public_item) && (model.type == :audio || model.type == :video) && model.prepared? } do |model, options|
          case model.type
            when :video
              model.video.audio.url
            when :audio
              model.audio.url
          end
        end

        expose :meta, as: :metadata, using: Narra::API::Entities::MetaItem, if: lambda { |model, options| options[:type] == :detail_item || options[:type] == :public_item } do |model, options|
          if options[:type] == :public_item
            model.meta.select { |meta| meta.public }
          else
            model.meta
          end
        end
      end
    end
  end
end