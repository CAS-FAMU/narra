#
# Copyright (C) 2018 CAS / FAMU
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
# Authors: Michal Mocnak <michal@marigan.net>
#

module Narra
  module API
    module Modules
      class UploadV1 < Narra::API::Modules::Generic

        version 'v1', :using => :path
        format :json

        helpers Narra::API::Helpers::User
        helpers Narra::API::Helpers::Error
        helpers Narra::API::Helpers::Present
        helpers Narra::API::Helpers::Generic
        helpers Narra::API::Helpers::Attributes

        resource :upload do

          desc "Upload possible item."
          post do
            required_attributes! [:files]
            # get authenticated
            authenticate!
            # get authorized
            error_not_authorized! unless authorize([:author]).size > 0
            # urls array
            urls = []
            # process files
            params[:files].each do |file|
              # create new upload
              upload = Narra::Upload.new
              # store file
              upload.filename = file[:filename]
              upload.file = file[:tempfile]
              # save
              upload.save!
              # retrieve urls from storage to serve
              urls << upload.file.url
            end
            # present uploaded files urls
            present_ok_generic(:files, urls)
          end

          get ':username' do
            return_one_custom(User, :username, true, [:author]) do |user, roles, public|
              # get authorized
              error_not_authorized! unless authorize([:admin]).size > 0 or params[:username] == user.username
              # present
              present_ok(user.uploads, Upload, Narra::API::Entities::Upload)
            end
          end
        end
      end
    end
  end
end