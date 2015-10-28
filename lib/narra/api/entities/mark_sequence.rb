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
      class MarkSequence < Grape::Entity

        include Narra::API::Helpers::Thumbnails

        expose :row

        expose :clip do |model, options|
          # get item if exists
          item = get_item(model.clip, options)
          # basic clip output
          if item.nil? || !item.prepared?
            output = {name: model.clip, thumbnail: model.clip == 'black' ? thumbnail_black : thumbnail_empty}
          else
            output = {id: item._id.to_s, name: model.clip, type: item.type, thumbnail: item.url_thumbnail}
          end
          # process
          unless item.nil?
            case item.type
              when :video
                output.merge!({source: item.video.url})
              when :image
                output.merge!({source: item.image.url})
              when :audio
                output.merge!({source: item.audio.url})
            end
          end
          # output
          output
        end

        expose :in do |model, options|
          # get item if exists
          item = get_item(model.clip, options)
          # check
          unless item.nil?
            # get start timecode
            start_tc = get_timecode(options[:sequence], item)
            # calculate time
            time = (model.in - start_tc).to_f
            # check
            time if time >= 0
          else
            nil
          end
        end

        expose :out do |model, options|
          # get item if exists
          item = get_item(model.clip, options)
          # check
          unless item.nil?
            # get start timecode
            start_tc = get_timecode(options[:sequence], item)
            # calculate time
            time = (model.out - start_tc).to_f
            # check
            time if time >= 0
          else
            nil
          end
        end

        expose :duration do |model, options|
          model.out - model.in
        end

        protected

        def get_item(name, options)
          # get item if exists
          @item ||= options[:sequence].models.find_by(name: name)
        end

        def get_timecode(sequence, item)
          # get timecode
          @timecode ||= item.get_meta(name: 'timecode', generator: :source)
          # start_tc
          value = Timecode.parse(@timecode.nil? ? '00:00:00:00' : @timecode.value, sequence.fps)
          # return timecode
          (value.to_f / sequence.fps).to_f
        end
      end
    end
  end
end