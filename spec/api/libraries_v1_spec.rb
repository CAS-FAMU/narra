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


require 'spec_helper'

describe Narra::API::Modules::LibrariesV1 do
  before(:each) do
    # create items
    @item_01 = FactoryGirl.create(:item, owner: @author_user)
    @item_02 = FactoryGirl.create(:item, owner: @author_user)

    # create libraries
    @library = FactoryGirl.create(:library, owner: @author_user)
    @library_admin = FactoryGirl.create(:library, owner: @admin_user)
    @library_items = FactoryGirl.create(:library, owner: @author_user, items: [@item_01, @item_02])
  end

  context 'not authenticated' do
    describe 'GET /v1/libraries' do
      it 'returns libraries' do
        get '/v1/libraries'

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
        get '/v1/libraries/' + @library.name

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
        get '/v1/libraries/' + @library.name + '/items'

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
        get '/v1/libraries/' + @library.name + '/delete'

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
        post '/v1/libraries/new', {name: 'test', title: 'test'}

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
        post '/v1/libraries/' + @library.name + '/update', {title: 'test'}

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
        get '/v1/libraries' + '?token=' + @unroled_token

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
        get '/v1/libraries/' + @library.name + '?token=' + @unroled_token

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
        get '/v1/libraries/' + @library.name + '/items?token=' + @unroled_token

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
        get '/v1/libraries/' + @library_admin.name + '/delete' + '?token=' + @author_token

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
        post '/v1/libraries/new' + '?token=' + @unroled_token, {name: 'test', title: 'test'}

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
        post '/v1/libraries/' + @library_admin.name + '/update' + '?token=' + @author_token, {title: 'test'}

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
        get '/v1/libraries' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('libraries')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['libraries'].count).to match(3)
      end
    end

    describe 'GET /v1/libraries/[:name]' do
      it 'returns a specific library' do
        # send request
        get '/v1/libraries/' + @library.name + '?token=' + @author_token

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
        expect(data['library']['title']).to match(@library.title)
      end
    end

    describe 'GET /v1/libraries/[:name]/items' do
      it 'returns a specific library items' do
        # send request
        get '/v1/libraries/' + @library_items.name + '/items?token=' + @author_token

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
        get '/v1/libraries/' + @library.name + '/delete' + '?token=' + @author_token

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
        post '/v1/libraries/new' + '?token=' + @author_token, {name: 'test_library', title: 'Test Library', description: 'Test Library Description'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('library')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['library']['name']).to match('test_library')
        expect(data['library']['title']).to match('Test Library')
        expect(data['library']['description']).to match('Test Library Description')
        expect(data['library']['owner']['name']).to match(@author_user.name)
      end
    end

    describe 'POST /v1/libraries/[:name]/update' do
      it 'updates specific library' do
        # send request
        post '/v1/libraries/' + @library.name + '/update' + '?token=' + @author_token, {title: 'Test Library Updated', description: 'Test Library Description Updated'}

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
        expect(data['library']['title']).to match('Test Library Updated')
        expect(data['library']['description']).to match('Test Library Description Updated')
        expect(data['library']['owner']['name']).to match(@author_user.name)
      end
    end
  end
end