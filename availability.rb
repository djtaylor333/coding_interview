require 'json'
require 'date_core'

class Availability

    START_TIME = '2021-07-05T00:00'
    END_TIME = '2021-07-07T23:59'
    NEXT_DAY = "----------------------"

    def self.check_availability(*participants)
        participants.flatten!
        puts "Finding Open Schedules for the following participants:"
        puts "#{participants.join(', ')}"
        
        users = load_users(participants)
        schedules = load_schedules(users)
        free_time = output_free_times(schedules)
        times = flatten_free_times(free_time)

        puts "This is when #{participants.join(', ')} is/are available:"
        puts times
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
            u["schedule"] = []
            events.each do |e|
                if e["user_id"] == u["id"]
                    start_time = DateTime.parse(e["start_time"])
                    end_time = DateTime.parse(e["end_time"])
                    u["schedule"] << [start_time, end_time]
                end
            end
        end
    end

    def self.output_free_times(user_schedules)
        start_time = DateTime.parse(START_TIME)
        end_time = DateTime.parse(END_TIME)

        available_times = []
        check_time = start_time

        while check_time <= end_time do
            unavailable = user_schedules.any? do |schedules|
                schedules["schedule"].any? do |events|
                    (events[0]..events[1]).cover? check_time
                end
            end

            unavailable ? nil : available_times << check_time
            old_time = check_time
            check_time = increase_time(check_time)
            old_time.day != check_time.day ? available_times << nil : nil
        end

        available_times
    end

    def self.flatten_free_times(free_times)
        flattened_times = []
        first_time = free_times.first

        free_times.each_with_index do |time, i|
            if time == nil
                flattened_times << NEXT_DAY
                first_time = free_times[i+1]
                next
            end
            if free_times[i].minute + 1 == free_times[i+1]&.minute
                next
            elsif free_times[i].minute == 59 && free_times[i+1]&.minute == 0 && free_times[i].hour + 1 == free_times[i+1]&.hour
                next
            else
                flattened_times << "#{format("%04d", first_time.year)}-#{format("%02d", first_time.month)}-#{format("%02d", first_time.day)} #{format("%02d", first_time.hour)}:#{format("%02d", first_time.minute)} ---- #{format("%02d", time.hour)}:#{format("%02d", time.minute)}"
                first_time = free_times[i+1]
                next
            end
        end

        flattened_times
    end

    private

    def self.increase_time(check_time)
        
        year = check_time.year
        month = check_time.month

        hour = check_time.minute == 59 ? check_time.hour + 1 : check_time.hour
        minute = check_time.minute == 59 ? 0 : check_time.minute + 1
        new_time = DateTime.new(year, month, check_time.day, hour, minute)
    end
end