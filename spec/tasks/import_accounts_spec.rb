require 'rails_helper'
require 'rake'

RSpec.describe 'accounts:import' do
  before :all do
    Rake.application = Rake::Application.new
    Rake.application.rake_require 'tasks/import_accounts'
    Rake::Task.define_task(:environment)
  end

  it 'imports accounts from a valid file path' do
    valid_file_path = 'path/to/valid_csv_file.csv'
    expect { Rake.application.invoke_task("accounts:import[#{valid_file_path}]") }.to change { Account.count }.by(3)
  end

  it 'returns an error message for an invalid file path' do
    invalid_file_path = ''
    expect(STDOUT).to receive(:puts).with("Please provide a valid file path.")
    Rake.application.invoke_task("accounts:import[#{invalid_file_path}]")
  end
end
```