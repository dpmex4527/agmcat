require 'json'
require 'terminal-table/import'
require 'reverse_markdown'
require 'time'

module Agmcat
  module CLI
    desc 'Migrate user stories from HPE AGM into GitHub'
    long_desc %{
      Start user story migrations from AGM using provided workspace and release IDs.
      To see available list of workspaces and releases associated to them, run inspect command.
    }
    arg 'workspace_id'
    arg 'release_id'
    command :migrate do |c|
      c.action do |global_options,options,args|
        workspace_id = args[0]
        release_id = args[1]

        puts "Migrating all user stories from workspace #{workspace_id} and release #{release_id}\n\n"

        # get env vars
        github_user = global_options['github_user']
        github_token = global_options['github_token']
        github_repo = global_options['github_repo']
        client_id = global_options['agm_id']
        client_secret = global_options['agm_secret']
        api_url = global_options['agm_url']
        proxy = global_options['proxy']

        # TODO: add code that checks all required inputs are valid

        # create client
        now = Time.now
        g = Agmcat::GitHub.new(github_user, github_token, github_repo, proxy)
        took = Time.now - now
        puts "took #{took} time to create client"

        # create agm client
        now = Time.now
        a = Agmcat::Agm.new(client_id, client_secret, api_url, proxy)
        took = Time.now - now
        puts "took #{took} time to authenticate agm client"

        # get list of user stories using workspace_id and release_id
        now = Time.now
        user_stories = a.list_user_stories_from_release(workspace_id,release_id)
        took = Time.now - now
        puts "took #{took} time to get user stories from workspace #{workspace_id} release #{release_id}"
        puts "\n"

        num_stories = user_stories.size
        u_rows = []

        user_stories.each do |user_story|
          u_name             = user_story['name']
          u_id               = user_story['id']
          u_description      = ReverseMarkdown.convert user_story['description']
          u_sprint_id        = user_story['sprint_id']
          u_status           = user_story['status']
          u_author           = user_story['author']
          u_assigned_to      = user_story['assigned_to']
          u_sprint_id        = user_story['sprint_id']
          u_application_id   = user_story['application_id']
          u_kanban_status_id = user_story['kanban_status_id']

          u_rows << [u_name,u_id,u_description,u_status,u_author,u_assigned_to]
        end

        u_table = Terminal::Table.new :title => "User stories to migrate", :headings => ['Name', 'Id', 'Description','Status','Author','Assigned to'], :rows => u_rows

        puts "The following user stories will be migrated from workspace #{workspace_id} and release #{release_id}"
        puts u_table
        puts "\n"

        i_rows = []

        user_stories.each do |user_story|
          # create issue
          u_name             = user_story['name']
          u_description      = ReverseMarkdown.convert user_story['description']
          u_status           = user_story['status']

          name = u_name
          body = u_description

          issue = g.create_issue(name,body,[''])
          issue_num = issue['number']

          if u_status == "New" || u_status == "In Progress"
            issue_state = "open"
          else
            issue_state = "closed"
          end

          # ensure issue state
          issue       = g.edit_issue(issue_num,{ 'state' => issue_state})
          issue_name  = issue['title']
          issue_num   = issue['number']
          issue_url   = issue['url']
          issue_state = issue['state']

          i_rows << [issue_name,issue_num,issue_url,issue_state]
        end

        u_table = Terminal::Table.new :title => "Issues created", :headings => ['Name', 'Issue number', 'Url','Status'], :rows => i_rows

        puts "The following issues were created\n"
        puts u_table
      end
    end
  end
end
