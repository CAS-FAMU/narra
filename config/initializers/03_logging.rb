#
# Copyright (C) 2017 CAS / FAMU
#
# This file is part of Narra.
#
# Narra is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Narra is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Narra. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Michal Mocnak <michal@marigan.net>
#

# Mongoid logging setup
Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

if Rails.env.development?
  # Narra logging setup
  Narra::Tools::Logger.default_logger.level = Logger::DEBUG
else
  # Narra logging setup
  Narra::Tools::Logger.default_logger.level = Logger::ERROR
end