require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phonenum(homePhone)
  homePhone = homePhone.gsub(/[^0-9]/, '')
  homePhone.sub(/^./, '') if homePhone.start_with?("1")
  homePhone if homePhone.length == 10
end

def reg_hour(date)
  formatted_date = Time.strptime(date, "%m/%d/%Y %k:%M")
end

def reg_day(date)
  formatted_date = Time.strptime(date, "%m/%d/%Y %k:%M")
  puts formatted_date.wday
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  phonenumber = clean_phonenum(row[:homephone])

  hours = reg_hour(row[:regdate])

  day = reg_day(row[:regdate])
  
end
