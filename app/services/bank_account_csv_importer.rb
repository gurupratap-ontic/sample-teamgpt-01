require 'csv'

class BankAccountCsvImporter
  def initialize(file)
    @file = file
  end

  def import
    ActiveRecord::Base.transaction do
      CSV.foreach(@file, headers: true) do |row|
        account_params = row.to_h.symbolize_keys
        validate_account_params(account_params)

        account = BankAccount.find_or_initialize_by(account_number: account_params[:account_number])
        account.update!(account_params)
      end
    end
  rescue => e
    raise "Error importing CSV: #{e.message}"
  end

  private

  def validate_account_params(account_params)
    required_keys = %i[customer_name account_number account_type balance IFSC_code]
    missing_keys = required_keys - account_params.keys

    raise "Missing columns: #{missing_keys.join(', ')}" unless missing_keys.empty?

    # Validate IFSC_code and account_type values
    raise "Invalid IFSC code: #{account_params[:IFSC_code]}" unless valid_ifsc_code?(account_params[:IFSC_code])
    raise "Invalid account type: #{account_params[:account_type]}" unless valid_account_type?(account_params[:account_type])

    # Validate balance for non-negative values
    raise "Negative balance not allowed: #{account_params[:balance]}" if account_params[:balance].to_f < 0
  end

  def valid_ifsc_code?(ifsc_code)
    # Add IFSC_code validation logic
  end

  def valid_account_type?(account_type)
    # Add account_type validation logic
  end
end
