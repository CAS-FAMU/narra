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

require 'rails_helper'

describe Narra::API::Modules::ItemsV1 do
  before(:each) do
    # create scenarios
    @scenario_library = FactoryGirl.create(:scenario_library, author: @author_user)
    @scenario_project = FactoryGirl.create(:scenario_project, author: @author_user)

    # create libraries
    @library_01 = FactoryGirl.create(:library, author: @author_user, scenario: @scenario_library, contributors: [@contributor_user])
    @library_02 = FactoryGirl.create(:library, author: @author_user, scenario: @scenario_library)
    @library_03 = FactoryGirl.create(:library, author: @admin_user, scenario: @scenario_library)

    # create metadata
    @meta_src_01 = FactoryGirl.create(:meta_item, :source)
    @meta_src_02 = FactoryGirl.create(:meta_item, :source)

    # create items
    @item = FactoryGirl.create(:item, library: @library_01)
    @item_admin = FactoryGirl.create(:item, library: @library_03)
    @item_meta = FactoryGirl.create(:item, library: @library_02, meta: [@meta_src_01, @meta_src_02])

    # create projects for testing purpose
    @project = FactoryGirl.create(:project, author: @author_user, scenario: @scenario_project, contributors: [@contributor_user], libraries: [@library_03])

    # create events
    @event = FactoryGirl.create(:event, item: @item)
  end

  context 'not authenticated' do
    describe 'GET /v1/items' do
      it 'returns items' do
        get "/v1/items"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/items/[:id]' do
      it 'returns a specific item' do
        get "/v1/items/#{@item._id}"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/items/[:id]/delete' do
      it 'deletes a specific item' do
        get "/v1/items/#{@item._id}/delete"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/items/new' do
      it 'creates new item' do
        post "/v1/items/new", params: {items: [{url: 'test', library: 'test', connector: 'testing'}]}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/items/[:id]/events' do
      it 'returns item events' do
        get "/v1/items/#{@item._id}/events"

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
    describe 'GET /v1/items' do
      it 'returns items' do
        get "/v1/items", params: {token: @author_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/items/[:id]' do
      it 'returns a specific item' do
        get "/v1/items/#{@item._id}", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/items/[:id]' do
      it 'returns a specific item as contributor' do
        get "/v1/items/#{@item_meta._id}", params: {token: @contributor_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/items/[:id]/delete' do
      it 'deletes a specific item' do
        get "/v1/items/#{@item_admin._id}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/items/new' do
      it 'creates new item' do
        post "/v1/items/new", params: {token: @unroled_token, items: [{url: 'test', library: 'test', connector: 'testing'}]}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/items/[:id]/events' do
      it 'returns item events' do
        get "/v1/items/#{@item_admin._id}/events", params: {token: @author_token}

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
    describe 'GET /v1/items' do
      it 'returns items' do
        # send request
        get "/v1/items", params: {token: @admin_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('items')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['items'].count).to match(3)
      end
    end

    describe 'GET /v1/items/[:id]' do
      it 'returns a specific item' do
        # send request
        get "/v1/items/#{@item_meta._id}", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('item')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['item']['name']).to match(@item_meta.name)
        expect(data['item']['url']).to match(@item_meta.url)
        expect(data['item']['metadata'].count).to match(2)
      end
    end

    describe 'GET /v1/items/[:id]' do
      it 'returns a specific item as contributor' do
        # send request
        get "/v1/items/#{@item._id}", params: {token: @contributor_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('item')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['item']['name']).to match(@item.name)
        expect(data['item']['url']).to match(@item.url)
        expect(data['item']['metadata'].count).to match(0)
      end
    end

    describe 'GET /v1/items/[:id]' do
      it 'returns a specific item as contributor of parent' do
        # send request
        get "/v1/items/#{@item_admin._id}", params: {token: @contributor_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('item')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['item']['name']).to match(@item_admin.name)
        expect(data['item']['url']).to match(@item_admin.url)
        expect(data['item']['metadata'].count).to match(0)
      end
    end

    describe 'GET /v1/items/[:id]/delete' do
      it 'deletes a specific item' do
        # send request
        get "/v1/items/#{@item._id}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')

        # check if the user is deleted
        expect(Narra::Item.find(@item._id)).to be_nil
      end
    end

    describe 'POST /v1/items/new' do
      it 'creates new item' do
        # send request
        post "/v1/items/new", params: {token: @author_token, items: [{url: 'http://test', library: @library_01._id.to_s, connector: 'testing', metadata: {meta_01: 'Meta 01', meta_02: 'Meta 02'}}]}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('items')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['items'].count).to match(1)
      end
    end

    describe 'GET /v1/items/[:id]/events' do
      it 'returns item events' do
        get "/v1/items/#{@item._id}/events", params: {token: @author_token}

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
        expect(data['events'][0]['status']).to match('pending')
        expect(data['events'][0]).to have_key('item')
      end
    end
  end
end