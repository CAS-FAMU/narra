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
      class Sequence < Grape::Entity

        expose :id do |model, options|
          model._id.to_s
        end
        expose :name, :description, :fps

        expose :author do |model, options|
          { username: model.author.username, name: model.author.name}
        end

        expose :prepared do |model, options|
          model.prepared?
        end

        expose :public do |model, options|
          model.is_public?
        end

        include Narra::API::Entities::Thumbnails

        expose :contributors do |model, options|
          model.contributors.collect { |user| {username: user.username, name: user.name} }
        end

        expose :meta, as: :metadata, using: Narra::API::Entities::Meta, if: {type: :detail_sequence}

        expose :marks, if: {type: :detail_sequence} do |model, options|
          Narra::API::Entities::MarkSequence.represent model.marks.order_by('row asc'), options.merge(sequence: model)
        end
      end
    end
  end
end