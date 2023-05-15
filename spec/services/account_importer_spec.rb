require 'rails_helper'

RSpec.describe AccountImporter, type: :service do
  let(:valid_csv_file_path) { 'path/to/valid_csv_file.csv' }
  let(:invalid_csv_file_path) { 'path/to/invalid_csv_file.csv' }

  it 'imports valid accounts from the CSV file' do
    importer = AccountImporter.new(valid_csv_file_path)
    expect { importer.import_accounts }.to change { Account.count }.by(3)
  end

  it 'logs errors and continues importing for invalid accounts' do
    importer = AccountImporter.new(invalid_csv_file_path)
    expect(Rails.logger).to receive(:error).with("Failed to import account: <error message>")
    expect { importer.import_accounts }.to change { Account.count }.by(2)
  end
end
