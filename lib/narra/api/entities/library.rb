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
      class Library < Grape::Entity

        expose :id do |model, options|
          model._id.to_s
        end

        expose :name, :title, :description

        expose :owner do |model, options|
          { username: model.owner.username, name: model.owner.name}
        end

        expose :thumbnails, if: lambda { |model, options| !model.url_thumbnails.nil? && !model.url_thumbnails.empty? } do |model, options|
          model.url_thumbnails
        end

        expose :projects, format_with: :projects, :if => {:type => :detail_library}

        format_with :projects do |projects|
          projects.collect { |project| {id: project._id.to_s, name: project.name, title: project.title, owner: {id: project.owner._id.to_s, name: project.owner.name}} }
        end
      end
    end
  end
end