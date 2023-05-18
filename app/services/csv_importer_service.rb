ruby
require 'csv'

class CsvImporterService
  def initialize(file_path)
    @file_path = file_path
  end

  def import
    ActiveRecord::Base.transaction do
      CSV.foreach(@file_path, headers: true).with_index(2) do |row, line_number|
        account_params = row.to_h.symbolize_keys
        account = BankAccount.find_or_initialize_by(account_number: account_params[:account_number])
        account.update!(account_params)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "CSV Import Error: Invalid account data at line #{line_number} - #{e.message}"
        raise "CSV Import Error: Invalid account data at line #{line_number} - #{e.message}"
      end
    rescue CSV::MalformedCSVError => e
      Rails.logger.error "CSV Import Error: Malformed CSV file - #{e.message}"
      raise "CSV Import Error: Malformed CSV file - #{e.message}"
    rescue StandardError => e
      Rails.logger.error "CSV Import Error: #{e.message}"
      raise "CSV Import Error: #{e.message}"
    end
  end
end