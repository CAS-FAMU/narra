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
      class Project < Grape::Entity

        expose :name, :title, :description, :generators
        expose :author do |model, options|
          { username: model.author.username, name: model.author.name}
        end
        expose :thumbnails, if: lambda { |model, options| !model.url_thumbnails.nil? && !model.url_thumbnails.empty? } do |model, options|
          model.url_thumbnails
        end
        expose :contributors do |model, options|
          model.contributors.collect { |user| { username: user.username, name: user.name} }
        end
        expose :libraries, using: Narra::API::Entities::Library, :if => {:type => :detail_project}
      end
    end
  end
end