require_relative 'availability.rb'

describe 'Availability' do
    let(:users) { ["John", "Maggie"] }
    subject{ Availability.check_availability(users) }

    describe 'check_availability' do
        context 'finding available schedules' do
            it 'logs info about script run' do
                allow(Availability).to receive(:flatten_free_times).and_return("TIMES")
                expect(STDOUT).to receive(:puts).with("Finding Open Schedules for the following participants:")
                expect(STDOUT).to receive(:puts).with(users.join(', '))
                expect(STDOUT).to receive(:puts).with(("This is when John, Maggie is/are available:"))
                expect(STDOUT).to receive(:puts).with("TIMES")
                subject
            end

            it 'returns open schedules' do
                # subject
            end
        end
    end

    describe 'load_users' do
        let!(:users) { ["John", "Maggie"] }
        
        subject{ Availability.load_users(users) }

        context 'when a user enterred does not match an user in the users file' do
            let!(:users) { ["Bob", "Maggie"] }

            it 'logs a warning that the user is not found' do
                expect(STDOUT).to receive(:puts).with("[WARNING] User Bob was not found in the user file. No Schedules Can be loaded, and this user will be ignored")
                subject
            end
        end

        it 'reads a users file' do
            expect(File).to receive(:read).with('users.json').and_call_original
            subject
        end

        it 'json parses the file' do
            expect(JSON).to receive(:parse).and_call_original
            subject
        end

        it 'turns the users into an array of hashes' do
            expect(subject).to eq( [{"id"=>2, "name"=>"John"}, {"id"=>3, "name"=>"Maggie"}] )
        end
    end

    describe 'load_schedules' do
        let(:users) { [{"id"=>2, "name"=>"Bob"}] }

        subject{ Availability.load_schedules(users) }

        it 'reads a events file' do
            expect(File).to receive(:read).with('events.json').and_call_original
            subject
        end

        it 'json parses the file' do
            expect(JSON).to receive(:parse).and_call_original
            subject
        end

        it 'updates the users array of hashes with the times from the events' do
            scheduled = [[DateTime.parse("2021-07-05T13:30:00+00:00"), DateTime.parse("2021-07-05T15:00:00+00:00")],
                [DateTime.parse("2021-07-06T14:00:00+00:00"), DateTime.parse("2021-07-06T14:30:00+00:00")],
                [DateTime.parse("2021-07-07T14:00:00+00:00"),DateTime.parse("2021-07-07T14:30:00+00:00")]]
            expect(subject).to eq( [{"id"=>2, "name"=>"Bob", "schedule"=>scheduled}] )
        end
    end

    describe 'output_free_times' do
        let(:schedules) { [{"id"=>2, "name"=>"John", "schedule"=>[]}] }

        subject { Availability.output_free_times(schedules) }
        it 'outputs the available times for the users' do


            expect(subject.count).to eq(4323) #every minute of everyday for 3 days
        end
    end

    describe 'flatten_free_times' do
        let(:times) { [DateTime.parse("2021-07-07 00:00"), DateTime.parse("2021-07-07 00:01"), DateTime.parse("2021-07-07 00:02"), DateTime.parse("2021-07-07 00:03")]  }
        subject { Availability.flatten_free_times(times) }
       
        it "flattens the array of times" do
            expect(subject).to eq(["2021-07-07 00:00 ---- 00:04"])
        end
    end
end

