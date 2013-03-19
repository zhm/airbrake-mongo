
require 'bundler/setup'
require 'thor'
require 'airbrake-api'
require 'mongo'

include Mongo

class AirbrakeSync < Thor
  desc "Sync Airbrake", "Sync airbrake to a local database"
  method_option :account, aliases: "-a", desc: "Airbrake account", required: false
  method_option :token,   aliases: "-t", desc: "Airbrake token",   required: false
  method_option :project, aliases: "-p", desc: "Airbrake project", required: false
  def sync
    AirbrakeAPI.configure(account: options[:account], auth_token: options[:token], :secure => true)

    page = 1

    while current_page = airbrake_errors(options[:project], page)
      puts "Page #{page}"
      current_page.each do |error|
        if not errors_collection.find_one(id: error['id'])
          errors_collection.insert(AirbrakeAPI.error(error['id']))
          notice_page = 1
          while (current_notice_page = AirbrakeAPI.notices(error['id'], page: notice_page) || []).any?
            puts "Notice page #{notice_page}"
            notice_page = notice_page + 1
            current_notice_page.each do |notice|
              if not notices_collection.find_one(id: notice['id'])
                notices_collection.insert(notice)
              end
            end
          end
        end
      end
      page = page + 1
    end
  end

  no_tasks do
    def airbrake_errors(project, page)
      AirbrakeAPI.errors(project_id: project, page: page)
    end

    def mongo_client
      @client ||= MongoClient.new("localhost", 27017)
    end

    def mongo_database
      @db ||= mongo_client.db("airbrake")
    end

    def errors_collection
      @errors ||= mongo_database.collection("errors")
    end

    def notices_collection
      @notices ||= mongo_database.collection("notices")
    end
  end
end

AirbrakeSync.start
