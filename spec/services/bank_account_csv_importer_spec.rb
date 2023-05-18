require 'rails_helper'

RSpec.describe BankAccountCsvImporter, type: :service do
  let(:csv_file) { 'spec/fixtures/bank_accounts.csv' }
  let(:importer) { BankAccountCsvImporter.new(csv_file) }

  it 'imports bank account data from a valid CSV file' do
    expect { importer.import }.to change { BankAccount.count }.by(2)
  end

  it 'raises an error if the CSV file is missing required columns' do
    invalid_csv_file = 'spec/fixtures/bank_accounts_invalid.csv'
    importer = BankAccountCsvImporter.new(invalid_csv_file)

    expect { importer.import }.to raise_error(/Missing columns:/)
  end

  # Additional tests for various error scenarios (e.g., invalid file format, invalid data, duplicate account numbers)
  # Include tests for invalid IFSC_code, account_type, and negative balance values
end
```