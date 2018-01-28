require 'json'
require 'rest-client'
require 'time'

system("clear")

# User Input Fields

puts "Enter your GoogleMaps API Key:"
key = gets.chomp

puts "Enter current address:"
origin = gets.chomp

puts "Enter destination address:"
destination = gets.chomp

puts "Enter departure time (Format: HH:MM PM/AM), or type 'now': "
departure_time = gets.chomp



# Receive departure time



if departure_time == "now"
  departure_time = Time.now
else
  if Time.parse(departure_time)
    departure_time = Time.parse(departure_time)
  else
    raise "Invalid time format"
  end
end

url = "https://maps.googleapis.com/maps/api/distancematrix/json?"

searchParams = {
  key: key,
  origins: origin,
  destinations: destination
}

res =  RestClient.get url, { params: searchParams }

res = JSON.parse(res)

system("clear")


# Handle error response


if res["rows"][0]["elements"][0]["status"] == "NOT_FOUND"
  puts "Error: Check your addresses."
else


# Parse through response and extract information (duration, distance)

  dur_values = res["rows"][0]["elements"][0]["duration"]["text"].split(" ")

  distance = res["rows"][0]["elements"][0]["distance"]["text"].split(" ")[0].to_i

  if dur_values.length == 4
    duration_hrs = res["rows"][0]["elements"][0]["duration"]["text"].split(" ")[0].to_i
    duration_min = res["rows"][0]["elements"][0]["duration"]["text"].split(" ")[2].to_i
    duration_in_min = (duration_hrs * 60) + duration_min
  else
    duration_in_min = res["rows"][0]["elements"][0]["duration"]["text"].split(" ")[0].to_i
  end


# Calculate the estimated arrival time based on user input


  arrival_time = departure_time + (duration_in_min * 60)

  puts "It is #{Time.now.strftime("%I:%M %p")}"

  if duration_in_min >= 60
    if duration_hrs == 1
      puts "#{res["destination_addresses"][0]} is #{duration_hrs} hour, #{duration_min} minutes and #{(distance * 0.62137119).round(2)} miles away."
    else
      puts "#{res["destination_addresses"][0]} is #{duration_hrs} hours, #{duration_min} minutes and #{(distance * 0.62137119).round(2)} miles away."
    end
  else
    puts "#{searchParams[:destinations]} is #{duration_in_min} minutes and #{(distance * 0.62137119).round(2)} miles away."

  end


  puts "Leaving at #{departure_time.strftime("%I:%M %p")}, you will arrive at #{arrival_time.strftime("%I:%M %p")}"

end
