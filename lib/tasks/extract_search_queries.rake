desc "extract search queries"
task :extract_search_queries, [:from, :to, :limit] => [:environment] do |t, args|
  p "start"
  start = Time.now
  puts start
  number = 0
  number_missing = 0
  number_csv_missing = 0
  number_ind_missing = 0
  from = args.from.to_s
  to = args.to.to_s

  file_for_warning_messages = "log/missing search records.log"
  FileUtils.mkdir_p(File.dirname(file_for_warning_messages))
  message_file = File.new(file_for_warning_messages, "w")
  message_file.puts 'query,created,search record, type,owned by,present, forename,surname, role'
  searches = SearchQuery.between(_id: from..to).count
  p "#{searches} to be examined"
  SearchQuery.between(_id: from..to).order_by(_id: 1).no_timeout.each do |query|
    number += 1
    break if number > args.limit.to_i

    next if query.blank?

    next if query.result_count.blank?

    next if query.result_count.zero?

    # next if query.result_count == 500

    p "#{query.result_count} for #{query.id}"
    query.search_result.records.each do |record_array|
      search_record = SearchRecord.find_by(id: record_array[0])
      # p "#{record_array[0]} is present" if search_record.present?
      next if search_record.present?

      number_missing += 1
      record = record_array[1]
      if record[:freecen_csv_entry_id].present?
        number_csv_missing += 1
        entry = FreecenCsvEntry.find_by(id: record[:freecen_csv_entry_id])
        entry_detail = entry.present? ? 'present' : 'Not present'
        message_file.puts "#{query.id}, #{query.c_at}, #{record_array[0]},csv,#{record[:freecen_csv_entry_id]},#{entry_detail},#{record[:transcript_names][0]},#{record[:transcript_names][1]},#{record[:transcript_names][2]}"
        piece = Freecen2Piece.find_by(id: record[:freecen2_piece_id])
        district = Freecen2District.find_by(id: record[:freecen2_district_id])
        place = Freecen2Place.find_by(id: record[:freecen2_place_id])
        entry.translate_individual(piece, district, record[:chapman_code], place, record[:freecen_csv_file_id])
      elsif record[:freecen_individual_id].present?
        number_ind_missing += 1
        individual = FreecenIndividual.find_by(id: record[:freecen_individual_id])
        individual_detail = individual.present? ? 'present' : 'Not present'
        message_file.puts "#{query.id}, #{query.c_at}, #{record_array[0]},vld,#{record[:freecen_individual_id]},#{individual_detail},#{record[:transcript_names][0]},#{record[:transcript_names][1]},#{record[:transcript_names][2]}"
        translate_individual(individual, record[:chapman_code], record[:record_type], record[:freecen1_vld_file_id]) if individual_detail == 'present'
      else
        p 'neither fish nor foul'
      end
    end
  end
  number -= 1
  p "finished #{number} queries examined #{number_missing} missing search records of which #{number_csv_missing} were csv and #{number_ind_missing} were individuals "
  puts Time.now
  elapse = Time.now - start
  puts elapse
end

def translate_date(individual, census_year)
  age = individual.age.to_i
  age_unit = individual.age_unit

  adjustment = 0 # this is all we need to do for day and week age units
  if age_unit == 'y'
    adjustment = 0 - age
  end

  if age_unit == 'm'
    if census_year == RecordType::CENSUS_1841
      # Census day: June 6, 1841
      #
      # Ages in the 1841 Census
      #    The census takers were instructed to give the exact ages of children
      # but to round the ages of those older than 15 down to a lower multiple of 5.
      # For example, a 59-year-old person would be listed as 55. Not all census
      # enumerators followed these instructions. Some recorded the exact age;
      # some even rounded the age up to the nearest multiple of 5.
      #
      # Source: http://familysearch.org/learn/wiki/en/England_Census:_Further_Information_and_Description
      adjustment = -1 if age > 6
    elsif census_year == RecordType::CENSUS_1851
      # Census day: March 30, 1851
      adjustment = -1 if age > 3
    elsif census_year == RecordType::CENSUS_1861
      # Census day: April 7, 1861
      adjustment = -1 if age > 4
    elsif census_year == RecordType::CENSUS_1871
      # Census day: April 2, 1871
      adjustment = -1 if age > 4
    elsif census_year == RecordType::CENSUS_1881
      # Census day: April 3, 1881
      adjustment = -1 if age > 4
    elsif census_year == RecordType::CENSUS_1891
      # Census day: April 5, 1891
      adjustment = -1 if age > 4
    end
  end

  birth_year = census_year.to_i + adjustment

  "#{birth_year}-*-*"
end

def translate_individual(individual, chapman_code, full_year, file_id)
  # create the search record for the person
  transcript_name = { first_name: individual.forenames, last_name: individual.surname, type: 'primary' }

  transcript_date = translate_date(individual, full_year)

  record = SearchRecord.new(transcript_dates: [transcript_date], transcript_names: [transcript_name], chapman_code: chapman_code, record_type: full_year, freecen1_vld_file_id: file_id)
  record.place_id = individual.freecen_dwelling.freecen_piece.place_id if individual.freecen_dwelling.present? && individual.freecen_dwelling.freecen_piece.present?
  record.birth_chapman_code = individual.verbatim_birth_county if individual.verbatim_birth_county.present?
  record.birth_chapman_code = individual.birth_county if individual.birth_county.present?
  record.birth_place = individual.verbatim_birth_place if individual.verbatim_birth_place.present?
  record.birth_place = individual.birth_place if individual.birth_place.present?
  record.freecen_individual = individual
  record.transform
  record.add_digest
  record.save!
end
