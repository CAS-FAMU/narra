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


require 'spec_helper'

describe Narra::API::Modules::EventsV1 do
  before(:each) do
    # create libraries
    @library = FactoryGirl.create(:library, owner: @author_user)

    # create items
    @item = FactoryGirl.create(:item, library: @library, owner: @author_user)

    # create events
    @event = FactoryGirl.create(:event, item: @item)
  end

  context 'not authenticated' do
    describe 'GET /v1/events' do
      it 'returns events' do
        get '/v1/events'

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end
  end

  context 'not authorized' do
    describe 'GET /v1/events' do
      it 'returns events' do
        get '/v1/events' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end
  end

  context 'authenticated & authorized' do
    describe 'GET /v1/events' do
      it 'returns events' do
        # send request
        get '/v1/events' + '?token=' + @admin_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('events')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['events'].count).to match(1)
        expect(data['events'][0]['message']).to match(@event.message)
        expect(data['events'][0]).to have_key('item')
        expect(data['events'][0]['item']['id']).to match(@item._id.to_s)
      end
    end
  end
end