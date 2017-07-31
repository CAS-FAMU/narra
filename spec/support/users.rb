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

RSpec.configure do |config|
  config.before(:each) do
    # get admin token
    @admin_paylaod = {:uid => @admin_user.email}
    @admin_token = ::JWT.encode @admin_paylaod, Narra::JWT::RSA_PRIVATE, 'RS256'
    # get author token
    @author_paylaod = {:uid => @author_user.email}
    @author_token = ::JWT.encode @author_paylaod, Narra::JWT::RSA_PRIVATE, 'RS256'
    # get contributor token
    @contributor_paylaod = {:uid => @contributor_user.email}
    @contributor_token = ::JWT.encode @contributor_paylaod, Narra::JWT::RSA_PRIVATE, 'RS256'
    # get guest token
    @unroled_paylaod = {:uid => @unroled_user.email}
    @unroled_token = ::JWT.encode @unroled_paylaod, Narra::JWT::RSA_PRIVATE, 'RS256'
  end
end