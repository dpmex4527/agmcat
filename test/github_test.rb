require 'test_helper'
require 'agmcat/github'

class DefaultGitHub < Test::Unit::TestCase

  def setup
    @github_user = ENV['GITHUB_USER_NAME']
    @github_token = ENV['GITHUB_API_TOKEN']
    @github_repo = ENV['GITHUB_REPOSITORY']
    @proxy = ENV['HTTP_PROXY']


    @g = Agmcat::GitHub.new(@github_user, @github_token, @github_repo, @proxy)
  end

  def test_param_nil_user
    assert_raise ArgumentError do
      Agmcat::GitHub.new(nil, 'super_secret_key', 'https://github.com/ghost/answer_to_the_universe', '')
    end
  end

  def test_param_empty_user
    assert_raise ArgumentError do
      Agmcat::GitHub.new('', 'super_secret_key', 'https://github.com/ghost/answer_to_the_universe', '')
    end
  end

  def test_param_nil_token
    assert_raise ArgumentError do
      Agmcat::GitHub.new('ghost', nil, 'https://github.com/ghost/answer_to_the_universe', '')
    end
  end

  def test_param_empty_token
    assert_raise ArgumentError do
      Agmcat::GitHub.new('ghost', '', 'https://github.com/ghost/answer_to_the_universe', '')
    end
  end

  def test_param_nil_repo
    assert_raise ArgumentError do
      Agmcat::GitHub.new('ghost', 'super_secret_key', nil, '')
    end
  end

  def test_param_empty_repo
    assert_raise ArgumentError do
      Agmcat::GitHub.new('ghost', 'super_secret_key', '', '')
    end
  end

  def test_create_issue
    issue = @g.create_issue("test issue","issue body",[''])
    issue_state = issue['state']
    assert_kind_of(Hash,issue)
    assert_equal('open', issue_state)
  end

  def test_edit_issue
    issue = @g.create_issue("test issue","issue body",[''])
    issue_num = issue['number']

    issue = @g.edit_issue(issue_num,"state" => "closed")
    issue_num = issue['number']
    issue_state = issue['state']

    assert_kind_of(Hash,issue)
    assert_equal('closed', issue_state)
  end
end
