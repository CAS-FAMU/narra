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

        expose :name, :title, :description
        expose :author do |model, options|
          { username: model.author.username, name: model.author.name }
        end

        expose :synthesizers, if: {type: :detail_project} do |project, options|
          project.synthesizers.collect { |synthesizer|
            {
                identifier: synthesizer[:identifier],
                title: Narra::Core.synthesizer(synthesizer[:identifier]).title,
                description: Narra::Core.synthesizer(synthesizer[:identifier]).description,
                options: synthesizer[:options]
            }
          }
        end

        expose :visualizations, if: {type: :detail_project} do |project, options|
          # process
          project.visualizations.collect { |visualization|
            # get model
            model = Narra::Visualization.find(visualization[:id])
            {
                id: visualization[:id],
                name: model.name,
                type: visualization[:type],
                description: model.description,
                options: visualization[:options].nil? ? model.options : visualization[:options]
            }
          }
        end

        expose :public do |model, options|
          model.is_public?
        end

        include Narra::API::Entities::Thumbnails

        expose :contributors do |model, options|
          model.contributors.collect { |user| {username: user.username, name: user.name} }
        end
        expose :libraries, using: Narra::API::Entities::Library, :if => {:type => :detail_project}

        expose :meta, as: :metadata, using: Narra::API::Entities::MetaProject, if: {type: :detail_project} do |project, options|
          # get scoped metadata for project
          Narra::MetaProject.where(project: project)
        end
      end
    end
  end
end