require 'rest-client'
require 'json'
require 'time'
require 'uri'

module Agmcat

  # Client for Agm API
  #
  # @see http://agmhelp.saas.hp.com/en/Latest/Help/Content/API_Reference/Integration.htm
  class Agm
    attr_reader :api_url
    attr_reader :access_token
    attr_reader :token_timestamp
    attr_reader :access_token_expires
    attr_reader :access_token_timestamp

    def initialize(client_id, client_secret, api_url, proxy)
      raise ArgumentError.new("missing arguments : client_id cannot be empty") if client_id == nil || client_id == ''
      raise ArgumentError.new("missing arguments : client_secret cannot be empty") if client_secret == nil || client_secret == ''
      raise ArgumentError.new("missing arguments : api_url cannot be empty") if api_url == nil || api_url == ''
      @client_id = client_id
      @client_secret = client_secret
      @api_url = api_url
      @proxy = proxy
      self.authenticate()
    end

    def authenticate()
      parameters = { :client_id => @client_id, :client_secret => @client_secret, :grant_type => 'client_credentials' }

      #puts @api_url + "/oauth/token"

      RestClient.proxy = @proxy
      r = RestClient.post @api_url + "/oauth/token",  parameters, :accept => :json

      token = JSON.parse(r.body)['access_token']
      expires = JSON.parse(r.body)['expires_in']

      @access_token = token
      @access_token_expires = expires
      @access_token_timestamp = Time.now.to_i
    end

    # Check if access_token has expired
    #
    # Checks to see if access_token has expired. If so then reauthenticate
    # Function will update @access_token with new one if expired.
    #
    # @return [No return]
    def isTokenExpired
      if Time.now.to_i - @access_token_timestamp >= access_token_expires
        puts "had to reauthenticate"
        self.authenticate
      end
    end

    # List AGM workspaces
    #
    # This function returns a list of available workspaces that user has access to.
    #
    # @return [Array of Hashes] Returns a list of workspace hashes
    def list_workspaces()
      # check and reauthenticate
      self.isTokenExpired()

      results = []
      url = @api_url + "/api/workspaces"
      headers = {:accept => :json, :authorization => "bearer #{@access_token}"}

      RestClient.proxy = @proxy

      begin
        r = RestClient.get url, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      workspaces = JSON.parse(r.body)['data']
      #release_count = JSON.parse(r.body)['TotalResults']

      #puts "workspaces dump is #{JSON.pretty_generate(workspaces)}\nworkspace count is #{release_count}"

      workspaces.each do |workspace|
        results.push(workspace)
      end
      return results
    end

    # List AGM releases
    #
    # This function returns a list of available relesease that user has access to.
    # in a given workspace.
    #
    # @param workspace_id [String] Workspace ID of workspace user has access to
    # @return [Array of Hashes]    Returns a list of resource hashes
    def list_releases(workspace_id)
      # check and reauthenticate
      self.isTokenExpired()

      results = []
      url = @api_url + "/api/workspaces/#{workspace_id}/releases"
      headers = {:accept => :json, :authorization => "bearer #{@access_token}"}

      RestClient.proxy = @proxy

      begin
        r = RestClient.get url, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      releases = JSON.parse(r.body)['data']
      #release_count = JSON.parse(r.body)['TotalResults']

      #puts "releases dump is #{JSON.pretty_generate(releases)}\nrelease count is #{release_count}"

      releases.each do |release|
        results.push(release)
      end
      return results
    end

    # List AGM applications
    #
    # This function returns a list of available applications that user has access to
    # in a given workspace.
    #
    # @param workspace_id [String] Workspace ID of workspace user has access to
    # @return [Array of Hashes]    Returns a list of application hashes
    def list_applications(workspace_id)
      # check and reauthenticate
      self.isTokenExpired()

      results = []
      url = @api_url + "/api/workspaces/#{workspace_id}/applications"
      headers = {:accept => :json, :authorization => "bearer #{@access_token}"}

      RestClient.proxy = @proxy

      begin
        r = RestClient.get url, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      applications = JSON.parse(r.body)['data']
      #application_count = JSON.parse(r.body)['TotalResults']

      #puts "applications dump is #{JSON.pretty_generate(applications)}\napplication count is #{application_count}"

      applications.each do |application|
        results.push(application)
      end
      return results
    end

    # List AGM user stories
    #
    # This function returns a list of available user stories that user has access to
    # in a given workspace.
    #
    # @param workspace_id [String] Workspace ID of workspace user has access to
    # @return [Array of Hashes]    Returns a list of user story hashes
    def list_user_stories(workspace_id)
      # check and reauthenticate
      self.isTokenExpired()

      results = []
      url = @api_url + "/api/workspaces/#{workspace_id}/backlog_items"
      headers = {:accept => :json, :authorization => "bearer #{@access_token}"}

      RestClient.proxy = @proxy

      begin
        r = RestClient.get url, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      user_stories = JSON.parse(r.body)['data']
      #user_story_count = JSON.parse(r.body)['TotalResults']

      #puts "user stories dump is #{JSON.pretty_generate(user_stories)}\nuser story count is #{user_story_count}"

      user_stories.each do |user_story|
        results.push(user_story)
      end
      return results
    end

    # List AGM user stories in a release
    #
    # This function returns a list of available user stories that user has access to
    # in a given workspace.
    #
    # @param workspace_id [String] Workspace ID of workspace user has access to
    # @param release_id   [String] Release ID of release that user stories are assigned to
    # @return [Array of Hashes]    Returns a list of user story hashes
    def list_user_stories_from_release( workspace_id, release_id )
      # check and reauthenticate
      self.isTokenExpired()

      results = []

      query = URI.encode_www_form("release_id" => "#{release_id}")
      fields = 'release_id,kanban_status_id,author,description,name,sprint_id,application_id,status,assigned_to'
      url = @api_url + "/api/workspaces/#{workspace_id}/backlog_items?query=\"" + "#{query}\"" + '&fields=' + fields
      headers = {:accept => :json, :authorization => "bearer #{@access_token}"}

      RestClient.proxy = @proxy

      begin
        r = RestClient.get url, headers
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end

      user_stories = JSON.parse(r.body)['data']
      #user_story_count = JSON.parse(r.body)['TotalResults']

      #puts "user stories dump is #{JSON.pretty_generate(user_stories)}\nuser story count is #{user_story_count}"

      user_stories.each do |user_story|
        results.push(user_story)
      end
      return results
    end
  end
end
