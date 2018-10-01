#
# Copyright (C) 2017 CAS / FAMU
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
  module JWT

    # generate rsa key if not in database
    rsa_temp = Narra::Tools::Settings.get('rsa_private')

    if rsa_temp.nil?
      # generate new rsa key
      RSA_PRIVATE = OpenSSL::PKey::RSA.generate 2048
      # save and store
      Narra::Tools::Settings.set('rsa_private', RSA_PRIVATE.to_s)
    else
      # load rsa key
      RSA_PRIVATE = OpenSSL::PKey::RSA.new(rsa_temp)
    end

    # generate public key from private
    RSA_PUBLIC = RSA_PRIVATE.public_key
  end
end