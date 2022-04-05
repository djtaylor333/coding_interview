# Background

Most calendar applications provide some kind of "meet with" feature where the user
can input a list of coworkers with whom they want to meet, and the calendar will
output a list of times where all the coworkers are available.

For example, say that we want to schedule a meeting with Jane, John, and Mary on Monday.

- Jane is busy from 9am - 10am, 12pm - 1pm, and 4pm - 5pm.
- John is busy from 9:30am - 11:00am and 3pm - 4pm
- Mary is busy from 3:30pm - 5pm.

Based on that information, our calendar app should tell us that everyone is available:
- 11:00am - 12:00pm
- 1pm - 3pm

We can then schedule a meeting during any of those available times.


# Instructions

Given the data in `events.json` and `users.json`, build a script that displays available times
for a given set of users. For example, your script might be executed like this:

```
python availability.py Maggie,Joe,Jordan
```

and would output something like this:

```
2021-07-05 13:30 - 16:00
2021-07-05 17:00 - 19:00
2021-07-05 20:00 - 21:00

2021-07-06 14:30 - 15:00
2021-07-06 16:00 - 18:00
2021-07-06 19:00 - 19:30
2021-07-06 20:00 - 20:30

2021-07-07 14:00 - 15:00
2021-07-07 16:00 - 16:15
```


For the purposes of this exercise, you should restrict your search between `2021-07-05` and `2021-07-07`,
which are the three days covered in the `events.json` file. You can also assume working hours between
`13:00` and `21:00` UTC, which is 9-5 Eastern (don't worry about any time zone conversion, just work in
UTC). Optionally, you could make your program support configured working hours, but this is not necessary.


## Data files

### `users.json`

A list of users that our system is aware of. You can assume all the names are unique (in the real world, maybe
they would be input as email addresses).

`id`: An integer unique to the user

`name`: The display name of the user - your program should accept these names as input.

### `events.json`

A dataset of all events on the calendars of all our users.

`id`: An integer unique to the event

`user_id`: A foreign key reference to a user

`start_time`: The time the event begins

`end_time`: The time the event ends


# Notes

- Please implement solution using Ruby
- Please provide instructions for execution of your program
- Please include a description of your approach to the problem, as well as any documentation about
  key parts of your code.
- You'll notice that all our events start and end on 15 minute blocks. However, this is not a strict
  requirement. Events may start or end on any minute (for example, you may have an event from 13:26 - 13:54).


## My Instructions

- I have created 3 files. 
1. meeting.rb - this file is the file that triggers the script run. This file can be run by enterring `ruby ./meeting.rb <names of users>`
For example `ruby ./meeting.rb Bob Maggie` would give you a list of days/times when Bob and Maggie are available
2. availability.rb - this files is the main file that the script runs. This does 4 steps; firstly takes the list of inputted users, and looks them up in the users.json file for matching users. Given they match an existing user (it warns if a user inputted is not in the file) it generates a hash of the user to a user id. Secondly, it looks at the events.json file and further generates a hash, by the hour and minute of day of availability, by looking at the schedule and "blocking" out those times. It does this by not adding the time to an arrary. The next step is that it compacts the array down into consecutive time periods and considers them a block. Finally, it outputs the remaining times in the hash that are deemed available on the users inputted and matches the matching times.
3. availability_spec.rb - this file is the set of tests I wrote for the Availability class, from a TDD perspective. You can run in using `rspec availability_spec.rb`

When running this file, assume you have a ruby environment, and the json and date/date_core gems are installed. These are the ones I rely on for the script.

## My Thought Process
When I first started I knew I wanted to have specs back up the flow I was doing. I started with a "higher" level spec, which was everything the script would do. Then as I was going along, I saw opportunities to break down the components, as are mentioned below. With each function I wanted to make sure they worked, so I wrote specs for those prior to implementation to flush out the functionality. I did go through some iterations and did come to simplifying/changing some specs depending on how detailed I wanted to be.

I went through multiple iterations of thoughts, but from a simple perspective I essentially imagined the smallest realistically quantifiable period of time, 1 minute. From there I thought, that would be the determining factor of whether that time period is free. This also lead me down the pathway of doing more time splices than was originally instructed. What I mean by that is, each day is a 24 hour period of 60 minute chunks. Therefore, a user might be considered free at midnight to 9am because they don't have anything during that time period. I was fine with that solution, due to the fact that one a real calendar app (like outlook) you can schedule anytime of day or night. The other reason was that it was easier to add time slices. I essentially began with a start period and end period that I was going to evaluate time (as indicated with the constants at the top of the file). This gave me my boundary of matching times.
The next thought was how I was going to match the users to the events. Firstly, I thought about looking at the users file, and putting that into a hash of user's names to ids. Now that I had the users, I could then match their events. I looked through the events file, and matching the user_id to that of a user, I created an array of schedules for each user in the hash. Each record in the array was comprised of the start and end time of an event found, i.e. [start_date_time, end_date_time] and this would make things easier later on. Once I had a complete hash of members and their existing events, it allowed me to move to the figuring out of free time.
This next step is where things got a bit tricky. Afetr generating the hash above, per user, I then went through each slice of time of day. I took each slice and checked to see if it was in between any period of time in any user's schedule array, essentially comparing the time slice to see if it was contained within a [start_date_time, end_date_time] event. Looping through all users and all schedules for those users, if it did not coincide with any existing event, I placed it an available time array.
Once every time slice between the days designated at the top of the file, I had to then flatten the array of times into a readable format. Essentially this meant finding blocks of time that were concurrent. This is the outputted time periods.

I added a little bit of error handling in the respect of testing whether a user event existed and giving a warning. I did make an assumption around the date times of the file being correctly formatted. If I were to do this again, I know that storing things in hashes isn't great from a performance perspective. What I would probably do is keep the users and events in some form of database, even a NoSQL database would work, indexing the events on user id, and then doing a lookup/comparison when needing to find a time period available. A further extension would be to figure out the time period of the event you want to schedule, whether it is 15mins or 2 hours, and try to find the slice of time when the users you want are free. It would also probably be useful to extract the events into event objects, users into user objects, and add error handling as well as validations on the various files.
