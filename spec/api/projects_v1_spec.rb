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

describe Narra::API::Modules::ProjectsV1 do
  before(:each) do
    # create item
    @item_01 = FactoryGirl.create(:item, owner: @author_user)
    @item_02 = FactoryGirl.create(:item, owner: @author_user)
    @item_03 = FactoryGirl.create(:item, owner: @author_user)
    @item_04 = FactoryGirl.create(:item, owner: @author_user)

    # create libraries
    @library_01 = FactoryGirl.create(:library, owner: @author_user, items: [@item_01])
    @library_02 = FactoryGirl.create(:library, owner: @author_user, items: [@item_02])
    @library_03 = FactoryGirl.create(:library, owner: @author_user, items: [@item_03])
    @library_04 = FactoryGirl.create(:library, owner: @author_user, items: [@item_04])

    # create projects for testing purpose
    @project = FactoryGirl.create(:project, owner: @author_user, libraries: [@library_01, @library_02])
    @project_admin = FactoryGirl.create(:project, owner: @admin_user, libraries: [@library_03, @library_04])

    # create sequences for testing purpose
    @sequence = FactoryGirl.create(:sequence, project: @project)
    @sequence_admin = FactoryGirl.create(:sequence, project: @project_admin)
  end

  context 'not authenticated' do
    describe 'GET /v1/projects' do
      it 'returns projects' do
        get '/v1/projects'

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('projects')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['projects'].count).to match(2)
      end
    end

    describe 'GET /v1/projects/[:name]' do
      it 'returns a specific project' do
        get '/v1/projects/' + @project.name

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/projects/[:name]/delete' do
      it 'deletes a specific project' do
        get '/v1/projects/' + @project.name + '/delete'

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/projects/new' do
      it 'creates new project' do
        post '/v1/projects/new', {name: 'test', title: 'test'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/projects/[:name]/update' do
      it 'updates a specific project' do
        post '/v1/projects/' + @project.name + '/update', {title: 'test'}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/projects/[:name]/libraries/add' do
      it 'adds specific libraries' do
        post '/v1/projects/' + @project.name + '/libraries/add', {libraries: [@library_03.name]}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'POST /v1/projects/[:name]/libraries/remove' do
      it 'removes specific libraries' do
        post '/v1/projects/' + @project.name + '/libraries/remove', {libraries: [@library_01.name]}

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/projects/[:name]/items' do
      it 'returns projects items' do
        get '/v1/projects/' + @project.name + '/items'

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/projects/[:name]/items/[:name]' do
      it 'returns projects item' do
        get '/v1/projects/' + @project.name + '/items/' + @item_01.name

            # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/projects/[:name]/sequences' do
      it 'returns projects sequences' do
        get '/v1/projects/' + @project.name + '/sequences'

        # check response status
        expect(response.status).to match(401)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authenticated')
      end
    end

    describe 'GET /v1/projects/[:name]/sequences/[:id]' do
      it 'returns projects sequence' do
        get '/v1/projects/' + @project.name + '/sequences/' + @sequence._id

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
    describe 'GET /v1/projects/[:name]' do
      it 'returns a specific project' do
        get '/v1/projects/' + @project_admin.name + '?token=' + @author_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/projects/[:name]/delete' do
      it 'deletes a specific project' do
        get '/v1/projects/' + @project.name + '/delete' + '?token=' + @unroled_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/projects/new' do
      it 'creates new project' do
        post '/v1/projects/new' + '?token=' + @unroled_token, {name: 'test', title: 'test'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/projects/[:name]/update' do
      it 'updates a specific project' do
        post '/v1/projects/' + @project_admin.name + '/update' + '?token=' + @author_token, {title: 'test'}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/projects/[:name]/libraries/add' do
      it 'adds specific libraries' do
        post '/v1/projects/' + @project_admin.name + '/libraries/add' + '?token=' + @author_token, {libraries: [@library_01.name]}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'POST /v1/projects/[:name]/libraries/remove' do
      it 'removes specific libraries' do
        post '/v1/projects/' + @project_admin.name + '/libraries/remove' + '?token=' + @author_token, {libraries: [@library_03.name]}

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/projects/[:name]/items' do
      it 'returns projects items' do
        get '/v1/projects/' + @project_admin.name + '/items' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/projects/[:name]/items/[:name]' do
      it 'returns projects item' do
        get '/v1/projects/' + @project_admin.name + '/items/' + @item_01.name + '?token=' + @author_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/projects/[:name]/sequences' do
      it 'returns projects sequences' do
        get '/v1/projects/' + @project_admin.name + '/sequences' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(403)

        # parse response
        data = JSON.parse(response.body)

        # check received data
        expect(data['status']).to match('ERROR')
        expect(data['message']).to match('Not Authorized')
      end
    end

    describe 'GET /v1/projects/[:name]/sequences/[:id]' do
      it 'returns projects sequence' do
        get '/v1/projects/' + @project_admin.name + '/sequences/' + @sequence_admin._id + '?token=' + @author_token

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
    describe 'GET /v1/projects/[:name]' do
      it 'returns a specific project' do
        # send request
        get '/v1/projects/' + @project.name + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('project')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['project']['name']).to match(@project.name)
        expect(data['project']['title']).to match(@project.title)
      end
    end

    describe 'GET /v1/projects/[:name]/delete' do
      it 'deletes a specific project' do
        # send request
        get '/v1/projects/' + @project.name + '/delete' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')

        # check received data
        expect(data['status']).to match('OK')

        # check if the user is deleted
        expect(Narra::Project.find(@project._id)).to be_nil
      end
    end

    describe 'POST /v1/projects/new' do
      it 'creates new project' do
        # send request
        post '/v1/projects/new' + '?token=' + @author_token, {name: 'test_project', title: 'Test Project', description: 'Test Project Description'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('project')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['project']['name']).to match('test_project')
        expect(data['project']['title']).to match('Test Project')
        expect(data['project']['description']).to match('Test Project Description')
        expect(data['project']['owner']['name']).to match(@author_user.name)
      end
    end

    describe 'POST /v1/projects/[:name]/update' do
      it 'creates new project' do
        # send request
        post '/v1/projects/' + @project.name + '/update' + '?token=' + @author_token, {title: 'Test Project Updated', description: 'Test Project Description Updated'}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('project')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['project']['name']).to match(@project.name)
        expect(data['project']['title']).to match('Test Project Updated')
        expect(data['project']['description']).to match('Test Project Description Updated')
        expect(data['project']['owner']['name']).to match(@author_user.name)
      end
    end

    describe 'POST /v1/projects/[:name]/libraries/add' do
      it 'adds specific libraries' do
        # send request
        post '/v1/projects/' + @project.name + '/libraries/add' + '?token=' + @author_token, {libraries: [@library_03.name, @library_04.name]}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('project')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['project']['name']).to match(@project.name)
        expect(data['project']['libraries'].count).to match(4)
      end
    end

    describe 'POST /v1/projects/[:name]/libraries/remove' do
      it 'removes specific libraries' do
        # send request
        post '/v1/projects/' + @project.name + '/libraries/remove' + '?token=' + @author_token, {libraries: [@library_01.name, @library_02.name]}

        # check response status
        expect(response.status).to match(201)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('project')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['project']['name']).to match(@project.name)
        expect(data['project']['libraries'].count).to match(0)
      end
    end

    describe 'GET /v1/projects/[:name]/items' do
      it 'returns projects items' do
        get '/v1/projects/' + @project.name + '/items' + '?token=' + @author_token

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

    describe 'GET /v1/projects/[:name]/items/[:name]' do
      it 'returns projects item' do
        get '/v1/projects/' + @project.name + '/items/' + @item_01.name + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('item')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['item']['name']).to match(@item_01.name)
      end
    end

    describe 'GET /v1/projects/[:name]/sequences' do
      it 'returns projects sequences' do
        get '/v1/projects/' + @project.name + '/sequences' + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('sequences')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['sequences'].count).to match(1)
      end
    end

    describe 'GET /v1/projects/[:name]/sequences/[:id]' do
      it 'returns projects sequence' do
        get '/v1/projects/' + @project.name + '/sequences/' + @sequence._id + '?token=' + @author_token

        # check response status
        expect(response.status).to match(200)

        # parse response
        data = JSON.parse(response.body)

        # check received data format
        expect(data).to have_key('status')
        expect(data).to have_key('sequence')

        # check received data
        expect(data['status']).to match('OK')
        expect(data['sequence']['id']).to match(@sequence._id.to_s)
        expect(data['sequence']).to have_key('playlist')
      end
    end
  end
end