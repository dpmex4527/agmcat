require 'test_helper'
require 'agmcat/agm'

class DefaultAgm < Test::Unit::TestCase

  def setup
    client_id = ENV['AGM_CLIENT_ID']
    client_secret = ENV['AGM_CLIENT_SECRET']
    api_url = ENV['AGM_API_URL']
    proxy = ENV['HTTP_PROXY']

    @a = Agmcat::Agm.new(client_id,client_secret, api_url, proxy)
    @workspace_id = '1000'
    @release_id = '1001'
  end

  def test_authenticate
    assert_not_nil(@a.access_token)
  end

  def test_list_workspaces
      workspaces = @a.list_workspaces()
      assert_kind_of(Array, workspaces)
  end

  def test_list_releases
      releases = @a.list_releases(@workspace_id)
      assert_kind_of(Array, releases)
  end

  def test_list_applications
      applications = @a.list_applications(@workspace_id)
      assert_kind_of(Array, applications)
  end

  def test_list_user_stories
    user_stories = @a.list_user_stories(@workspace_id)
    assert_kind_of(Array, user_stories)
  end

  def test_list_user_stories_from_release
    user_stories_release = @a.list_user_stories_from_release(@workspace_id,@release_id)
    assert_kind_of(Array, user_stories_release)
  end
end
