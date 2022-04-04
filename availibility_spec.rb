require_relative 'availability.rb'

describe 'Availability' do
    let(:users) { ["John", "Maggie"] }
    subject{ Availability.check_availability(users) }

    describe 'check_availability' do
        context 'finding available schedules' do
            it 'logs info about script run' do
                expect(STDOUT).to receive(:puts).with("Finding Open Schedules for the following participants:")
                expect(STDOUT).to receive(:puts).with(users.join(', '))
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
        let(:users) { [{"id"=>2, "name"=>"John"}] }

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
            expect(subject).to eq( [{"id"=>2, "name"=>"John", "schedule"=>{}}] )
        end
    end

    describe 'output_free_times' do
        it 'outputs the available times for the users' do
            subject
        end
    end
end

