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

        expose :row

        expose :clip do |model, options|
          # basic clip output
          basic = {id: model.clip._id.to_s, name: model.clip.name, type: model.clip.type, thumbnail: model.clip.url_thumbnail}
          # process
          case model.clip.type
            when :video
              basic.merge({source: model.clip.video.url})
            when :image
              basic.merge({source: model.clip.image.url})
            when :audio
              basic.merge({source: model.clip.audio.url})
          end
        end

        expose :in
        expose :out
      end
    end
  end
end