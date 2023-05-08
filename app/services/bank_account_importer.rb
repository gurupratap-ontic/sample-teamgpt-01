
```ruby
require 'csv'

class BankAccountImporter
  attr_reader :error_log

  def initialize(file_path)
    @file_path = file_path
    @error_log = []
  end

  def import
    raise "File not found: #{@file_path}" unless File.exist?(@file_path)

    CSV.foreach(@file_path, headers: true) do |row|
      import_record(row)
    end
  rescue StandardError => e
    @error_log << "Error importing CSV file: #{e.message}"
  end

  private

  def import_record(record)
    bank_account = BankAccount.find_or_initialize_by(account_number: record['account_number'])
    bank_account.attributes = {
      customer_name: record['customer_name'],
      account_type: record['account_type'],
      balance: record['balance'],
      IFSC_code: record['IFSC_code']
    }

    if bank_account.valid?
      bank_account.save!
    else
      error_message = "Error importing record: #{record.inspect}. Errors: #{bank_account.errors.full_messages}"
      @error_log << error_message
      puts error_message
    end
  end
end
```
#####