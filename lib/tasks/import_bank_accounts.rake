ruby
namespace :import do
  desc 'Import bank accounts from a CSV file'
  task :bank_accounts, [:file_path] => :environment do |_task, args|
    file_path = args[:file_path]
    raise "File path is required" if file_path.blank?

    CsvImporterService.new(file_path).import
  end
end