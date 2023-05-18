require 'csv'

class CsvImporter
  def initialize(file_path)
    @file_path = file_path
  end

  def import
    summary = { processed: 0, imported: 0, errors: 0 }
    ActiveRecord::Base.transaction do
      CSV.foreach(@file_path, headers: true, encoding: 'bom|utf-8') do |row|
        summary[:processed] += 1
        account = Account.new(account_params(row))
        if account.save
          summary[:imported] += 1
        else
          summary[:errors] += 1
          # Log errors with row number and error details
          Rails.logger.error("Error importing row #{summary[:processed]}: #{account.errors.full_messages.join(', ')}")
        end
      end
    end
    summary
  end

  private

  def account_params(row)
    {
      customer_name: row['customer_name'],
      account_number: row['account_number'],
      account_type: row['account_type'],
      balance: row['balance'],
      IFSC_code: row['IFSC_code']
    }
  end
end
