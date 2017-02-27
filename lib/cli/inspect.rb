require 'json'
require 'terminal-table/import'
require 'reverse_markdown'
require 'time'

module Agmcat

  module CLI
    desc 'Inspect HPE AGM workspaces and releases.'
    long_desc %{
      Run this command to see a list of available workspaces and releases associated to each workspace.
      This command will provide the workspace and release ID's needed for migrate command.
    }
    command :inspect do |c|
      c.action do |global_options,options,args|
        puts "Inspecting HPE AGM. This could take a while...grab a soda?\n\n"

        client_id = global_options['agm_id']
        client_secret = global_options['agm_secret']
        api_url = global_options['agm_url']
        proxy = global_options['proxy']

        # TODO: add code that checks all required inputs are valid

        # create client
        now = Time.now
        a = Agmcat::Agm.new(client_id, client_secret, api_url, proxy)
        took = Time.now - now
        puts "took #{took} time to authenticate"

        # get list of workspaces
        now = Time.now
        workspaces = a.list_workspaces()
        took = Time.now - now
        puts "took #{took} time to get workspaces"

        # result data. 2xn , [[w_rows],[array of r_rows]]
        inspect_results = []

        workspaces.each do |workspace|
          w_name = workspace['name']
          w_id = workspace['id']
          w_description = ReverseMarkdown.convert workspace['description']

          w_rows =[]
          w_rows << [w_name,w_id,w_description]

          r_rows = []

          now = Time.now
          # Get releases for this workspace
          releases = a.list_releases(w_id)
          took = Time.now - now
          puts "took #{took} time to get releases for workspace #{w_id}"

          releases.each do |release|
            r_name        = release['name']
            r_id          = release['id']
            r_description = ReverseMarkdown.convert release['description']

            now = Time.now
            user_stories = a.list_user_stories_from_release(w_id,r_id)
            took = Time.now - now
            puts "took #{took} time to get user stories from workspace #{w_id} release #{r_id}"

            num_stories = user_stories.size

            r_rows << [r_name,r_id,r_description,num_stories]
          end

          inspect_results << [w_rows,r_rows]
        end

        puts "Workspace info and their releases are shown below.\n\n"

        inspect_results.each do |w_rows,r_rows|
          w_table = Terminal::Table.new :title => "HPE AGM Workspace info", :headings => ['Name', 'Id', 'Description'], :rows => w_rows
          r_table = Terminal::Table.new :title => "Workspace Releases", :headings => ['Name', 'Id', 'Description', 'User story count'], :rows => r_rows

          puts w_table
          puts "\n"
          puts r_table
        end

        puts "To migrate user stories into GitHub, run \"agmcat migrate workspace_id release_id\" to migrate user stories\n\n"
      end
    end
  end
end
