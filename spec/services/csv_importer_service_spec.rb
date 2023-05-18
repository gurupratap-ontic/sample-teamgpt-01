ruby
require 'rails_helper'

RSpec.describe CsvImporterService, type: :service do
  let(:file_path) { 'spec/fixtures/bank_accounts.csv' }
  let!(:existing_account) { create(:bank_account, account_number: '1234567890') }
  subject { CsvImporterService.new(file_path) }

  context 'when the CSV file is valid' do
    it 'creates new bank accounts' do
      expect {
        subject.import
      }.to change(BankAccount, :count).by(2)
    end

    it 'updates existing bank accounts' do
      subject.import
      existing_account.reload
      expect(existing_account.customer_name).to eq('John Doe')
    end
  end

  context 'when the CSV file is malformed' do
    let(:file_path) { 'spec/fixtures/malformed_bank_accounts.csv' }

    it 'raises an error' do
      expect {
        subject.import
      }.to raise_error(/CSV Import Error: Malformed CSV file/)
    end
  end

  context 'when the CSV file contains invalid account data' do
    let(:file_path) { 'spec/fixtures/invalid_bank_accounts.csv' }

    it 'raises an error' do
      expect {
        subject.import
      }.to raise_error(/CSV Import Error: Invalid account data at line \d+/)
    end
  end

  context 'when there is an unexpected error' do
    let(:file_path) { 'spec/fixtures/non_existent_file.csv' }

    it 'raises an error' do
      expect {
        subject.import
      }.to raise_error(/CSV Import Error:/)
    end
  end
end