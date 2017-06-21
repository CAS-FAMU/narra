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

describe Narra::API::Modules::ItemsV1Metadata do
  before(:each) do
    # create libraries
    @library_01 = FactoryGirl.create(:library, author: @author_user)
    @library_02 = FactoryGirl.create(:library, author: @author_user)
    @library_03 = FactoryGirl.create(:library, author: @admin_user)

    # create metadata
    @meta_src_01 = FactoryGirl.create(:meta_item, :source)
    @meta_src_02 = FactoryGirl.create(:meta_item, :source)

    # create items
    @item = FactoryGirl.create(:item, library: @library_01)
    @item_admin = FactoryGirl.create(:item, library: @library_03)
    @item_meta = FactoryGirl.create(:item, library: @library_02, meta: [@meta_src_01, @meta_src_02])

    # create events
    @event = FactoryGirl.create(:event, item: @item)
  end

  context 'not authenticated' do
    describe 'GET /v1/items/[:id]/metadata' do
      it 'returns all meta' do
        get "/v1/items/#{@item._id}/metadata"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/items/[:id]/metadata/[:meta]' do
      it 'returns a specific meta' do
        get "/v1/items/#{@item._id}/metadata/#{@meta_src_01.name}", params: {generator: 'test'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/items/[:id]/metadata/new' do
      it 'creates new meta' do
        post "/v1/items/#{@item._id}/metadata/new", params: {meta: 'test', value: 'test', generator: 'test'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/items/[:id]/metadata/[:meta]/update' do
      it 'updates specific meta' do
        post "/v1/items/#{@item_meta._id}/metadata/#{@meta_src_01.name}/update", params: {value: 'updated', generator: @meta_src_01.generator}

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
    describe 'GET /v1/items/[:id]/metadata' do
      it 'returns all meta' do
        get "/v1/items/#{@item._id}/metadata", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/items/[:id]/metadata/[:meta]' do
      it 'returns a specific meta' do
        get "/v1/items/#{@item._id}/metadata/#{@meta_src_01.name}", params: {token: @unroled_token, generator: 'test'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/items/[:id]/metadata/new' do
      it 'creates new meta' do
        post "/v1/items/#{@item._id}/metadata/new", params: {token: @unroled_token, meta: 'test', value: 'test', generator: 'test'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/items/[:id]/metadata/update' do
      it 'updates specific meta' do
        post "/v1/items/#{@item._id}/metadata/#{@meta_src_01.name}/update", params: {token: @unroled_token, value: 'updated', generator: @meta_src_01.generator}

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
    describe 'GET /v1/items/[:id]/metadata' do
      it 'returns all meta' do
        get "/v1/items/#{@item_meta._id}/metadata", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata'].count).to match(2)
      end
    end

    describe 'GET /v1/items/[:id]/metadata/[:meta]' do
      it 'returns a specific meta' do
        get "/v1/items/#{@item_meta._id}/metadata/#{@meta_src_01.name}", params: {token: @author_token, generator: 'source'}

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata']['name']).to match(@meta_src_01.name)
        expect(data['metadata']['value']).to match(@meta_src_01.value)
        expect(data['metadata']['generator']).to match(@meta_src_01.generator.to_s)
      end
    end

    describe 'POST /v1/items/[:id]/metadata/new' do
      it 'creates new meta' do
        post "/v1/items/#{@item._id}/metadata/new", params: {token: @author_token, meta: 'test', value: 'test', generator: 'test'}

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata']['name']).to match('test')
        expect(data['metadata']['value']).to match('test')
        expect(data['metadata']['generator']).to match('test')
      end
    end

    describe 'POST /v1/items/[:id]/metadata/[:meta]update' do
      it 'updates specific meta' do
        post "/v1/items/#{@item_meta._id}/metadata/#{@meta_src_01.name}/update", params: {token: @author_token, value: 'updated', generator: @meta_src_01.generator}

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata']['name']).to match(@meta_src_01.name)
        expect(data['metadata']['value']).to match('updated')
        expect(data['metadata']['generator']).to  match(@meta_src_01.generator.to_s)
      end
    end
  end
end