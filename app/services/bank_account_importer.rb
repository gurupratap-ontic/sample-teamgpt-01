require 'csv'

class InvalidBankAccountDataError < StandardError; end
class MalformedCSVError < StandardError; end

class BankAccountImporter
  def import_from_csv(file_path)
    raise ArgumentError, 'File not found' unless File.exist?(file_path)

    total_records = 0
    skipped_records = 0

    CSV.foreach(file_path, headers: true, encoding: 'UTF-8') do |row|
      total_records += 1

      begin
        BankAccount.transaction do
          bank_account = BankAccount.new(
            customer_name: row['customer_name'],
            account_number: row['account_number'],
            account_type: row['account_type'],
            balance: row['balance'],
            IFSC_code: row['IFSC_code']
          )

          unless bank_account.valid?
            raise InvalidBankAccountDataError, "Invalid bank account data at row #{total_records}: #{bank_account.errors.full_messages.join(', ')}"
          end

          bank_account.save!
        end
      rescue InvalidBankAccountDataError => e
        Rails.logger.error e.message
        skipped_records += 1
      end
    end

    {
      total_records: total_records,
      skipped_records: skipped_records
    }
  rescue CSV::MalformedCSVError => e
    raise MalformedCSVError, "CSV file is malformed: #{e.message}"
  end
end
