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

describe Narra::API::Modules::UsersV1 do
  context 'not authenticated' do
    describe 'GET /v1/users' do
      it 'returns users' do
        get "/v1/users"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/users/me' do
      it 'returns logged user in the current session' do
        get "/v1/users/me"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/users/me/signout' do
      it 'signouts logged user in the current session' do
        get "/v1/users/me/signout"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/users/roles' do
      it 'returns all roles' do
        get "/v1/users/roles"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/users/[:username]' do
      it 'returns a specific user' do
        get "/v1/users/#{@unroled_user.username}"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/users/[:username]/delete' do
      it 'deletes a specific user' do
        get "/v1/users/#{@unroled_user.username}/delete"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/users/[:username]/update' do
      it 'updates a specific user' do
        post "/v1/users/#{@unroled_user.username}/update", params: {roles: ['author']}

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
    describe 'GET /v1/users/[:username]' do
      it 'returns a specific user' do
        get "/v1/users/#{@unroled_user.username}", params: {token: @author_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/users/[:username]/delete' do
      it 'deletes a specific user' do
        get "/v1/users/#{@unroled_user.username}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/users/[:username]/update' do
      it 'updates a specific user' do
        post "/v1/users/#{@unroled_user.username}/update", params: {token: @author_token, roles: ['author']}

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
    describe 'GET /v1/users' do
      it 'returns users' do
        # send request
        get "/v1/users", params: {token: @admin_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('users')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['users'].count).to match(4)
      end
    end

    describe 'GET /v1/users/me' do
      it 'returns logged user in the current session' do
        # send request
        get "/v1/users/me", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('user')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['user']['name']).to match(@unroled_user.name)
        expect(data['user']['email']).to match(@unroled_user.email)
      end
    end

    describe 'GET /v1/users/me/signout' do
      it 'signouts logged user in the current session' do
        # send request
        get "/v1/users/me/signout", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')
      end
    end

    describe 'GET /v1/users/[:username]' do
      it 'returns a specific user' do
        # send request
        get "/v1/users/#{@admin_user.username}", params: {token: @admin_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('user')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['user']['username']).to match(@admin_user.username)
        expect(data['user']['name']).to match(@admin_user.name)
        expect(data['user']['email']).to match(@admin_user.email)
        expect(data['user']['roles'].collect {|role| role.to_sym}).to match(@admin_user.roles)
      end
    end

    describe 'GET /v1/users/[:username]/delete' do
      it 'deletes a specific user' do
        # send request
        get "/v1/users/#{@unroled_user.username}/delete", params: {token: @admin_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')

        # check if the user is deleted
        expect(Narra::User.find(@unroled_user._id)).to be_nil
      end
    end

    describe 'POST /v1/users/[:username]/update' do
      it 'updates a specific user' do
        # send request
        post "/v1/users/#{@unroled_user.username}/update", params: {token: @admin_token, roles: ['author']}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')

        # check received data
        expect(data['user']['name']).to match(@unroled_user.name)
        expect(data['user']['email']).to match(@unroled_user.email)
        expect(data['user']['roles'].collect {|role| role.to_sym}).to match(@author_user.roles)
      end
    end
  end
end