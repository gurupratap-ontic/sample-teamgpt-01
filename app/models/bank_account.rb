
```ruby
class BankAccount < ActiveRecord::Base
  validates :customer_name, presence: true
  validates :account_number, presence: true, uniqueness: true, length: { maximum: 30 }
  validates :account_type, presence: true, length: { maximum: 30 }
  validates :balance, presence: true, numericality: true
  validates :IFSC_code, presence: true, length: { maximum: 15 }
end
```
##### 
### app/services/bank_account_import_service.rb

```ruby
require 'csv'

class BankAccountImportService
  def import_from_csv(file_path)
    raise ArgumentError, "File not found" unless File.exist?(file_path)

    processed_account_numbers = []

    ActiveRecord::Base.transaction do
      CSV.foreach(file_path, headers: true) do |row|
        validate_row(row)
        account_number = row['account_number']
        
        if processed_account_numbers.include?(account_number)
          raise StandardError.new("Duplicate account number found in file: #{account_number}")
        end

        bank_account = BankAccount.find_or_initialize_by(account_number: account_number)
        bank_account.update!(
          customer_name: row['customer_name'],
          account_type: row['account_type'],
          balance: row['balance'],
          IFSC_code: row['IFSC_code']
        )

        processed_account_numbers << account_number
      end
    end
  rescue CSV::MalformedCSVError => e
    raise StandardError.new("Invalid CSV format: #{e.message}")
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError.new("Invalid data: #{e.message}")
  end

  private

  def validate_row(row)
    required_columns = %w[customer_name account_number account_type balance IFSC_code]
    missing_columns = required_columns.select { |column| row[column].blank? }
    raise StandardError.new("Missing columns: #{missing_columns.join(', ')}") if missing_columns.any?
  end
end
```
##### 
### lib/tasks/import_csv.rake

```ruby
require 'bank_account_import_service'

namespace :bank_account do
  desc 'Import bank accounts from CSV file'
  task import_csv: :environment do |_, args|
    file_path = args[:file_path]

    if file_path.blank?
      abort "File path is required"
    end

    begin
      BankAccountImportService.new.import_from_csv(file_path)
      puts "Bank accounts imported successfully"
    rescue StandardError => e
      abort "Error: #{e.message}"
    end
  end
end
```
##### 
### spec/models/bank_account_spec.rb

```ruby
require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  it { should validate_presence_of(:customer_name) }
  it { should validate_presence_of(:account_number) }
  it { should validate_uniqueness_of(:account_number) }
  it { should validate_length_of(:account_number).is_at_most(30) }
  it { should validate_presence_of(:account_type) }
  it { should validate_length_of(:account_type).is_at_most(30) }
  it { should validate_presence_of(:balance) }
  it { should validate_numericality_of(:balance) }
  it { should validate_presence_of(:IFSC_code) }
  it { should validate_length_of(:IFSC_code).is_at_most(15) }
end
```
##### 
### spec/services/bank_account_import_service_spec.rb

```ruby
require 'rails_helper'
require 'bank_account_import_service'

RSpec.describe BankAccountImportService, type: :service do
  let(:csv_file_path) { 'spec/fixtures/bank_accounts.csv' }
  let(:invalid_csv_file_path) { 'spec/fixtures/invalid_bank_accounts.csv' }
  let(:non_existent_file_path) { 'spec/fixtures/non_existent.csv' }
  let(:csv_with_missing_columns) { 'spec/fixtures/csv_with_missing_columns.csv' }

  describe '#import_from_csv' do
    context 'when the CSV file is valid' do
      it 'imports bank accounts from the CSV file' do
        expect {
          BankAccountImportService.new.import_from_csv(csv_file_path)
        }.to change(BankAccount, :count)
      end
    end

    context 'when the CSV file is malformed' do
      it 'raises an error' do
        expect {
          BankAccountImportService.new.import_from_csv(invalid_csv_file_path)
        }.to raise_error(StandardError, "Invalid CSV format")
      end
    end

    context 'when the CSV file is missing required columns' do
      it 'raises an error' do
        expect {
          BankAccountImportService.new.import_from_csv(csv_with_missing_columns)
        }.to raise_error(StandardError, /Missing columns/)
      end
    end

    context 'when the CSV file is not found' do
      it 'raises an error' do
        expect {
          BankAccountImportService.new.import_from_csv(non_existent_file_path)
        }.to raise_error(ArgumentError, "File not found")
      end
    end
  end
end
```
##### 
### spec/tasks/import_csv_spec.rb

```ruby
require 'rails_helper'
require 'rake'

RSpec.describe 'bank_account:import_csv', type: :rake_task do
  let(:csv_file_path) { 'spec/fixtures/bank_accounts.csv' }
  let(:non_existent_file_path) { 'spec/fixtures/non_existent.csv' }
  let!(:task) { Rake::Task["bank_account:import_csv"] }

  before(:all) do
    Rake.application.rake_require('tasks/import_csv')
    Rake::Task.define_task(:environment)
  end

  after(:each) do
    task.reenable
  end

  it 'calls the BankAccountImportService with the correct file path' do
    expect_any_instance_of(BankAccountImportService).to receive(:import_from_csv).with(csv_file_path)
    task.invoke(csv_file_path)
  end

  it 'aborts with an error message if file_path is not provided' do
    expect { task.invoke }.to raise_error(SystemExit).and output("File path is required\n").to_stderr
  end

  it 'aborts with an error message if file_path is not found' do
    expect { task.invoke(non_existent_file_path) }.to raise_error(SystemExit).and output("Error: File not found\n").to_stderr
  end
end
```