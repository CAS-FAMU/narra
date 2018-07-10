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
    class Mounter < Grape::API

      format :json

      helpers Narra::API::Helpers::Error

      # Mount all the API modules
      Narra::API::Modules::Generic.descendants.each do |api|
        mount(api)
      end

      get do
        redirect '/v1/system/version'
      end

      # Catch all not resolved request and return not found error answer
      route :any, '*path' do
        error_not_found!
      end
    end
  end
end