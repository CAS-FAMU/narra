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
    module Entities
      class Event < Grape::Entity

        expose :id do |event, options|
          event._id.to_s
        end

        expose :message
        expose :progress
        expose :status

        expose :item, if: lambda { |event, options| !event.item.nil? } do |event, options|
          { id: event.item._id.to_s, name: event.item.name, type: event.item.type }
        end

        expose :project, if: lambda { |event, options| !event.project.nil? } do |event, options|
          { name: event.project.name }
        end

        expose :library, if: lambda { |event, options| !event.library.nil? } do |event, options|
          { id: event.library._id.to_s, name: event.library.name }
        end
      end
    end
  end
end