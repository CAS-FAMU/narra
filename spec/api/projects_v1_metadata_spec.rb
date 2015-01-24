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

describe Narra::API::Modules::ProjectsV1Metadata do
  before(:each) do
    # create metadata
    @meta_01 = FactoryGirl.create(:meta_project)
    @meta_02 = FactoryGirl.create(:meta_project)

    # create libraries
    @project = FactoryGirl.create(:project, author: @author_user, meta: [@meta_01, @meta_02])
  end

  context 'not authenticated' do
    describe 'GET /v1/projects/[:name]/metadata' do
      it 'returns all meta' do
        get '/v1/projects/' + @project.name + '/metadata'

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/projects/[:name]/metadata/[:name]' do
      it 'returns a specific meta' do
        get '/v1/projects/' + @project.name + '/metadata/' + @meta_01.name

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/projects/[:name]/metadata/new' do
      it 'creates new meta' do
        post '/v1/projects/' + @project.name + '/metadata/new', {name: 'test', value: 'test'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/projects/[:name]/metadata/update' do
      it 'updates specific meta' do
        post '/v1/projects/' + @project.name + '/metadata/' + @meta_01.name + '/update', {value: 'updated'}

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
    describe 'GET /v1/projects/[:name]/metadata' do
      it 'returns all meta' do
        get '/v1/projects/' + @project.name + '/metadata' + '?token=' + @unroled_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/projects/[:name]/metadata/[:name]' do
      it 'returns a specific meta' do
        get '/v1/projects/' + @project.name + '/metadata/' + @meta_01.name + '?token=' + @unroled_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/projects/[:name]/metadata/new' do
      it 'creates new meta' do
        post '/v1/projects/' + @project.name + '/metadata/new' + '?token=' + @unroled_token, {name: 'test', value: 'test'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/projects/[:name]/metadata/update' do
      it 'updates specific meta' do
        post '/v1/projects/' + @project.name + '/metadata/' + @meta_01.name + '/update' + '?token=' + @unroled_token, {value: 'updated'}

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
    describe 'GET /v1/projects/[:name]/metadata' do
      it 'returns all meta' do
        get '/v1/projects/' + @project.name + '/metadata' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata'].count).to match(3)
      end
    end

    describe 'GET /v1/projects/[:name]/metadata/[:name]' do
      it 'returns a specific meta' do
        get '/v1/projects/' + @project.name + '/metadata/' + @meta_01.name + '?token=' + @author_token

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata']['name']).to match(@meta_01.name)
        expect(data['metadata']['value']).to match(@meta_01.value)
      end
    end

    describe 'POST /v1/projects/[:name]/metadata/new' do
      it 'creates new meta' do
        post '/v1/projects/' + @project.name + '/metadata/new' + '?token=' + @author_token, {name: 'test', value: 'test'}

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata']['name']).to match('test')
        expect(data['metadata']['value']).to match('test')
      end
    end

    describe 'POST /v1/projects/[:name]/metadata/update' do
      it 'updates specific meta' do
        post '/v1/projects/' + @project.name + '/metadata/' + @meta_01.name + '/update' + '?token=' + @author_token, {value: 'updated'}

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('metadata')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['metadata']['name']).to match(@meta_01.name)
        expect(data['metadata']['value']).to match('updated')
      end
    end
  end
end