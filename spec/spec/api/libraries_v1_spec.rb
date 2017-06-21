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

require 'rails_helper'

describe Narra::API::Modules::LibrariesV1 do
  before(:each) do
    # create items
    @item_01 = FactoryGirl.create(:item)
    @item_02 = FactoryGirl.create(:item)

    # create libraries
    @library = FactoryGirl.create(:library, author: @author_user)
    @library_admin = FactoryGirl.create(:library, author: @admin_user)
    @library_contributor = FactoryGirl.create(:library, author: @author_user, contributors: [@contributor_user])
    @library_project_contributor = FactoryGirl.create(:library, author: @author_user)
    @library_items = FactoryGirl.create(:library, author: @author_user, items: [@item_01, @item_02])

    # create projects for testing purpose
    @project_contributor = FactoryGirl.create(:project, author: @author_user, contributors: [@contributor_user], libraries: [@library_project_contributor])
  end

  context 'not authenticated' do
    describe 'GET /v1/libraries' do
      it 'returns libraries' do
        get "/v1/libraries"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/libraries/[:name]' do
      it 'returns a specific library' do
        get "/v1/libraries/#{@library._id.to_s}"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/libraries/[:name]/items' do
      it 'returns a specific library items' do
        get "/v1/libraries/#{@library._id.to_s}/items"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/libraries/[:name]/delete' do
      it 'deletes a specific library' do
        get "/v1/libraries/#{@library._id.to_s}/delete"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/libraries/new' do
      it 'creates new library' do
        post "/v1/libraries/new", params: {name: 'test', title: 'test'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/libraries/[:name]/update' do
      it 'updates specific library' do
        post "/v1/libraries/#{@library._id.to_s}/update", params: {title: 'test'}

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
    describe 'GET /v1/libraries' do
      it 'returns libraries' do
        get "/v1/libraries", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/libraries/[:name]' do
      it 'returns a specific library' do
        get "/v1/libraries/#{@library._id.to_s}", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/libraries/[:name]/items' do
      it 'returns a specific library items' do
        get "/v1/libraries/#{@library._id.to_s}/items", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end


    describe 'GET /v1/libraries/[:name]/delete' do
      it 'deletes a specific library' do
        get "/v1/libraries/#{@library_admin._id.to_s}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/libraries/[:name]/delete' do
      it 'deletes a specific library as a contributor' do
        get "/v1/libraries/#{@library_contributor._id.to_s}/delete", params: {token: @contributor_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/libraries/new' do
      it 'creates new library' do
        post "/v1/libraries/new", params: {token: @unroled_token, name: 'test', title: 'test'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/libraries/[:name]/update' do
      it 'updates specific library' do
        post "/v1/libraries/#{@library_admin._id.to_s}/update", params: {token: @author_token, title: 'test'}

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
    describe 'GET /v1/libraries' do
      it 'returns libraries' do
        # send request
        get "/v1/libraries", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('libraries')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['libraries'].count).to match(4)
      end
    end

    describe 'GET /v1/libraries' do
      it 'returns libraries as contributor' do
        # send request
        get "/v1/libraries", params: {token: @contributor_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('libraries')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['libraries'].count).to match(2)
      end
    end

    describe 'GET /v1/libraries/[:name]' do
      it 'returns a specific library' do
        # send request
        get "/v1/libraries/#{@library._id.to_s}", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('library')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['library']['name']).to match(@library.name)
      end
    end

    describe 'GET /v1/libraries/[:name]' do
      it 'returns a specific library as a parent contributor' do
        # send request
        get "/v1/libraries/#{@library_project_contributor._id.to_s}", params: {token: @contributor_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('library')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['library']['name']).to match(@library_project_contributor.name)
      end
    end

    describe 'GET /v1/libraries/[:name]/items' do
      it 'returns a specific library items' do
        # send request
        get "/v1/libraries/#{@library_items._id.to_s}/items", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('items')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['items'].count).to match(2)
      end
    end

    describe 'GET /v1/libraries/[:name]/delete' do
      it 'deletes a specific library' do
        # send request
        get "/v1/libraries/#{@library._id.to_s}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')

        # check if the user is deleted
        expect(Narra::Library.find(@library._id)).to be_nil
      end
    end

    describe 'POST /v1/libraries/new' do
      it 'creates new library' do
        # send request
        post "/v1/libraries/new", params: {token: @author_token, name: 'Test Library', description: 'Test Library Description'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('library')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['library']['name']).to match('Test Library')
        expect(data['library']['description']).to match('Test Library Description')
        expect(data['library']['author']['name']).to match(@author_user.name)
      end
    end

    describe 'POST /v1/libraries/[:name]/update' do
      it 'updates specific library' do
        # send request
        post "/v1/libraries/#{@library._id.to_s}/update", params: {token: @author_token, description: 'Test Library Description Updated'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('library')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['library']['name']).to match(@library.name)
        expect(data['library']['description']).to match('Test Library Description Updated')
        expect(data['library']['author']['name']).to match(@author_user.name)
      end
    end
  end
end