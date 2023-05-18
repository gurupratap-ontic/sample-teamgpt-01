namespace :import_accounts do
  desc 'Import bank accounts data from a CSV file'
  task :import, [:file_path] => :environment do |_task, args|
    raise 'Please provide the file path as an argument' if args[:file_path].blank?

    csv_importer = CsvImporter.new(args[:file_path])
    summary = csv_importer.import
    puts "Processed: #{summary[:processed]}, Imported: #{summary[:imported]}, Errors: #{summary[:errors]}"
  end
end
