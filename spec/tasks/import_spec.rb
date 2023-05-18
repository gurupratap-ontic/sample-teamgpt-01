require 'rails_helper'
require 'rake'

RSpec.describe 'import:bank_accounts', type: :task do
  let(:csv_file_path) { 'spec/fixtures/bank_accounts.csv' }
  let(:invalid_csv_file_path) { 'spec/fixtures/invalid_bank_accounts.csv' }
  let(:nonexistent_file_path) { 'spec/fixtures/nonexistent.csv' }
  let(:empty_csv_file_path) { 'spec/fixtures/empty_bank_accounts.csv' }

  before do
    Rails.application.load_tasks
  end

  it 'imports bank account data from a valid CSV file' do
    expect { Rake::Task['import:bank_accounts'].execute(file_path: csv_file_path) }.to change { BankAccount.count }.by(2)
  end

  it 'handles error when the file does not exist' do
    expect { Rake::Task['import:bank_accounts'].execute(file_path: nonexistent_file_path) }.to raise_error(RuntimeError, /Failed to import bank account data/)
  end

  it 'handles error when the CSV file is malformed' do
    expect { Rake::Task['import:bank_accounts'].execute(file_path: invalid_csv_file_path) }.to raise_error(RuntimeError, /Failed to import bank account data/)
  end

  it 'handles empty CSV files or ones with only headers' do
    expect { Rake::Task['import:bank_accounts'].execute(file_path: empty_csv_file_path) }.not_to raise_error
  end
end
```