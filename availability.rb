require 'json'
require 'date_core'

class Availability
    def self.check_availability(*participants)
        participants.flatten!
        puts "Finding Open Schedules for the following participants:"
        puts "#{participants.join(', ')}"
        
        users = load_users(participants)
        schedules = load_schedules(users)
        output_free_times(schedules)
    end

    def self.load_users(participants)
        file = File.read('users.json')
        all_users = JSON.parse(file)
        users = []
    
        participants.each do |p|
            found = false

            all_users.each do |u|
                if u['name'].downcase == p.downcase
                    users << u 
                    found = true
                end
            end

            puts "[WARNING] User #{p} was not found in the user file. No Schedules Can be loaded, and this user will be ignored" unless found
        end

        users
    end

    def self.load_schedules(users)
        file = File.read('events.json')
        events = JSON.parse(file)

        users.each do |u|
            u["schedule"] = {}
            events.each do |e|
                if e["user_id"] == u["id"]
                    start_time = DateTime.parse(e["start_time"])
                    end_time = DateTime.parse(e["end_time"])
                end
            end
        end
    end

    def self.output_free_times(schedules)
    end
end

