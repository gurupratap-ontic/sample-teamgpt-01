
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
    rescue StandardError =>