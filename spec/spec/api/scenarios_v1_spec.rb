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

describe Narra::API::Modules::ScenariosV1 do
  before(:each) do
    # create scenarios
    @scenario = FactoryGirl.create(:scenario_library, author: @author_user)
    @scenario_admin = FactoryGirl.create(:scenario_library, author: @admin_user)
    @scenario_library = FactoryGirl.create(:scenario_library, author: @author_user)
    @scenario_project = FactoryGirl.create(:scenario_project, author: @author_user)
  end

  context 'not authenticated' do
    describe 'GET /v1/scenarios' do
      it 'returns scenarios' do
        get "/v1/scenarios"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/scenarios/[:id]' do
      it 'returns a specific scenario' do
        get "/v1/scenarios/#{@scenario._id.to_s}"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/scenarios/[:id]/delete' do
      it 'deletes a specific scenario' do
        get "/v1/scenarios/#{@scenario._id.to_s}/delete"

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/scenarios/new' do
      it 'creates new scenario' do
        post "/v1/scenarios/new", params: {name: 'test', type: 'library'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/scenarios/[:id]/update' do
      it 'updates specific scenario' do
        post "/v1/scenarios/#{@scenario._id.to_s}/update", params: {title: 'test'}

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
    describe 'GET /v1/scenarios' do
      it 'returns scenarios' do
        get "/v1/scenarios", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/scenarios/[:id]' do
      it 'returns a specific scenario' do
        get "/v1/scenarios/#{@scenario._id.to_s}", params: {token: @unroled_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/scenarios/[:id]/delete' do
      it 'deletes a specific scenario' do
        get "/v1/scenarios/#{@scenario_admin._id.to_s}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/scenarios/new' do
      it 'creates new scenario' do
        post "/v1/scenarios/new", params: {token: @unroled_token, name: 'test', title: 'test', type: 'library'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/scenarios/[:id]/update' do
      it 'updates specific scenario' do
        post "/v1/scenarios/#{@scenario_admin._id.to_s}/update", params: {token: @author_token, title: 'test'}

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
    describe 'GET /v1/scenarios' do
      it 'returns scenarios' do
        # send request
        get "/v1/scenarios", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenarios')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenarios'].count).to match(3)
      end
    end

    describe 'GET /v1/scenarios' do
      it 'returns scenarios as admin' do
        # send request
        get "/v1/scenarios", params: {token: @admin_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenarios')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenarios'].count).to match(4)
      end
    end

    describe 'GET /v1/scenarios/[:id]' do
      it 'returns a specific scenario' do
        # send request
        get "/v1/scenarios/#{@scenario._id.to_s}", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenario')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenario']['name']).to match(@scenario.name)
      end
    end

    describe 'GET /v1/scenarios/[:id]/delete' do
      it 'deletes a specific scenario' do
        # send request
        get "/v1/scenarios/#{@scenario._id.to_s}/delete", params: {token: @author_token}

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')

        # check if the user is deleted
        expect(Narra::Scenario.find(@scenario._id)).to be_nil
      end
    end

    describe 'POST /v1/scenarios/new' do
      it 'creates new project scenario' do
        # send request
        post "/v1/scenarios/new", params: {token: @author_token, name: 'Test Scenario', description: 'Test Scenario Description', type: 'project'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenario')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenario']['name']).to match('Test Scenario')
        expect(data['scenario']['description']).to match('Test Scenario Description')
        expect(data['scenario']['author']['name']).to match(@author_user.name)
        expect(data['scenario']['type']).to match('scenarioproject')
        expect(data['scenario']).to have_key('synthesizers')
        expect(data['scenario']).to have_key('layouts')
        expect(data['scenario']).to have_key('visualizations')
      end
    end

    describe 'POST /v1/scenarios/new' do
      it 'creates new library scenario' do
        # send request
        post "/v1/scenarios/new", params: {token: @author_token, name: 'Test Scenario', description: 'Test Scenario Description', type: 'library'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenario')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenario']['name']).to match('Test Scenario')
        expect(data['scenario']['description']).to match('Test Scenario Description')
        expect(data['scenario']['author']['name']).to match(@author_user.name)
        expect(data['scenario']['type']).to match('scenariolibrary')
        expect(data['scenario']).to have_key('generators')
      end
    end

    describe 'POST /v1/scenarios/[:id]/update' do
      it 'updates specific library scenario' do
        # send request
        post "/v1/scenarios/#{@scenario_library._id.to_s}/update", params: {token: @author_token, description: 'Test Scenario Description Updated', generators: [{identifier: 'testing', parameters: {}}]}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenario')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenario']['name']).to match(@scenario_library.name)
        expect(data['scenario']['description']).to match('Test Scenario Description Updated')
        expect(data['scenario']['author']['name']).to match(@author_user.name)
        expect(data['scenario']['type']).to match('scenariolibrary')
        expect(data['scenario']['generators'][0]['identifier']).to match('testing')
      end
    end

    describe 'POST /v1/scenarios/[:id]/update' do
      it 'updates specific project scenario' do
        # send request
        post "/v1/scenarios/#{@scenario_project._id.to_s}/update", params: {token: @author_token, description: 'Test Scenario Description Updated', synthesizers: [{identifier: 'testing', parameters: {}}], layouts: [{identifier: 'testing', parameters: {}}], visualizations: [{identifier: 'testing', parameters: {}}]}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('scenario')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['scenario']['name']).to match(@scenario_project.name)
        expect(data['scenario']['description']).to match('Test Scenario Description Updated')
        expect(data['scenario']['author']['name']).to match(@author_user.name)
        expect(data['scenario']['type']).to match('scenarioproject')
        expect(data['scenario']['synthesizers'][0]['identifier']).to match('testing')
        expect(data['scenario']['layouts']).to match([{'identifier' => 'testing'}])
        expect(data['scenario']['visualizations']).to match([{'identifier' => 'testing'}])
      end
    end
  end
end