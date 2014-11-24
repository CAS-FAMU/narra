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

        expose :message
        expose :progress
        expose :status

        expose :item, if: lambda { |model, options| options[:type] == :_event && !model.item.nil? } do |model, options|
          { id: model.item._id.to_s, name: model.item.name, type: model.item.type }
        end

        expose :project, if: lambda { |model, options| options[:type] == :_event && !model.project.nil? } do |model, options|
          { id: model.project._id.to_s, name: model.project.name }
        end
      end
    end
  end
end