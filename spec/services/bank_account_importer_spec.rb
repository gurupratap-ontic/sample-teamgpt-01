require 'rails_helper'

RSpec.describe BankAccountImporter, type: :service do
  let(:csv_file_path) { 'spec/fixtures/bank_accounts.csv' }
  let(:invalid_csv_file_path) { 'spec/fixtures/invalid_bank_accounts.csv' }
  let(:nonexistent_file_path) { 'spec/fixtures/nonexistent.csv' }
  let(:empty_csv_file_path) { 'spec/fixtures/empty_bank_accounts.csv' }

  subject { described_class.new }

  describe '#import_from_csv' do
    it 'imports bank account data from a valid CSV file' do
      expect { subject.import_from_csv(csv_file_path) }.to change { BankAccount.count }.by(2)
    end

    it 'raises an error when the CSV file is malformed' do
      expect { subject.import_from_csv(invalid_csv_file_path) }.to raise_error(MalformedCSVError, /CSV file is malformed/)
    end

    it 'raises an error when the file does not exist' do
      expect { subject.import_from_csv(nonexistent_file_path) }.to raise_error(ArgumentError, 'File not found')
    end

    it 'handles empty CSV files or ones with only headers' do
      expect { subject.import_from_csv(empty_csv_file_path) }.not_to raise_error
    end
  end
end
