require 'rest-client'
require 'json'
require 'time'
require 'uri'

module Agmcat

  # Client for GitHub api
  #
  # @see https://developer.github.com/v3/enterprise/
  class GitHub
    attr_reader :github_api_url
    attr_reader :github_user
    attr_reader :gitub_token
    attr_reader :github_repo

    def initialize(username, api_token, repository, proxy)
      raise ArgumentError.new("username cannot be empty") if username == nil || username == ''
      raise ArgumentError.new("api_token cannot be empty") if api_token == nil || api_token == ''
      raise ArgumentError.new("repository cannot be empty") if repository == nil || repository == ''
      @github_api_url = self.get_api_endpoint(repository)
      @github_user = username
      @gitub_token = api_token
      @github_repo = self.get_repo(repository)
      @proxy = proxy
    end

    # Extract GitHub api endpoints
    #
    # This function extracts the GitHub api endpoint that will be used based on provided repo.
    # It is smart enough to detect if using public GitHub instance or a private GitHub Enterprise instance
    #
    # @param repo [String] Repository we are using
    # @return [String]     GitHub API endpoint to use
    def get_api_endpoint(repo)
      u = URI.parse(repo)
      if u.host == 'github.com'
        return 'https://api.github.com'
      else
        return 'https://' + u.host + '/api/v3'
      end
    end

    def get_repo(repo)
      u = URI.parse(repo)
      return u.path
    end

    # Get a Github issue
    #
    # This function gets an issue from GitHub based on issue number
    #
    # @param issue_number [String] Repository we are using
    # @return             [Hash]   GitHub Issue as a hash
    def get_issue(issue_number)

      RestClient.proxy = @proxy

      url = @github_api_url + "/repos" + @github_repo + "/issues/#{issue_number}"
      headers = {:accept => :json, :content_type => :json, :authorization => "Bearer #{@gitub_token}"}

      r = RestClient.get url, headers

      issue = JSON.parse(r.body)
      return issue
    end

    # Create a Github issue
    #
    # This function creates an issue from GitHub based on issue number.
    # Issue is created against the user provided GitHub repository
    #
    # @param issue_title     [String] Repository we are using
    # @param issue_body      [String] Repository we are using
    # @param issue_assignees [Array]  Repository we are using
    # @return                [Hash]   Newly created GitHub Issue as a hash
    def create_issue(issue_title,issue_body,issue_assignees)
      RestClient.proxy = @proxy

      if issue_assignees.size == 0
        issue_assignees = ['']
      end

      url = @github_api_url + "/repos" + @github_repo + "/issues"
      headers = {:accept => :json, :content_type => :json, :authorization => "Bearer #{@gitub_token}"}
      body = { 'title' => issue_title, 'body' => issue_body, 'assignees' => issue_assignees }

      begin
        r = RestClient.post url,  body.to_json, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      issue = JSON.parse(r.body)
      #puts "issue is created. response is #{JSON.pretty_generate(issue)}"
      return issue
    end

    # Edit a GitHub issue
    #
    # This function creates an issue from GitHub based on issue number.
    # Issue is created against the user provided GitHub repository
    #
    # @param issue_num   [String] Repository we are using
    # @param params      [Hash]   Hash of issue fields we want to change
    # @return            [Hash]   Newly created GitHub Issue as a hash
    def edit_issue(issue_num,params)
      RestClient.proxy = @proxy

      url = @github_api_url + "/repos" + @github_repo + "/issues/#{issue_num}"
      headers = {:accept => :json, :content_type => :json, :authorization => "Bearer #{@gitub_token}"}

      begin
        r = RestClient.patch url, params.to_json, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      issue = JSON.parse(r.body)
      #puts "issue is created. response is #{JSON.pretty_generate(issue)}"
      return issue
    end
  end
end
