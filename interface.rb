require './lib/train'
require './lib/station'
require './lib/line'
require 'pg'
require 'pry'


DB = PG.connect({:dbname => 'train_system'})

def main_menu

  puts "\n\n"
  puts "Press 'o' to sign in as a system operator"
  puts "Type 's' to list all the stations and their lines"
  puts "Type 'v' to view all the lines and where they stop"
  puts "Type 'a' to check the arrival time of a train"
  print ">>"
  user_input = gets.chomp

  case user_input
  when 's'
    list_stations
  when 'v'
    list_lines
  when 'o'
    administration
  when 'a'
    schedule
  end

end

def administration
  puts "Type 'a' to add a train station"
  puts "Type 'l' to add a new line"
  puts "Type 'c' to change a line's route"
  puts "Press 'd' to delete"
  puts "Or Press 'm' to return to the Main Menu"
  input = gets.chomp

  case input
  when 'a'
    add_station
  when 'l'
    add_line
  when 'd'
    delete
  when 'c'
    change_route
  when 'm'
    main_menu
  end

end

def add_station
  puts "\nWhere is this Station located? "
  print ">"
  location = gets.chomp
  station = Station.new({:location => location})
  station.save
  puts "#{station.location} has been saved!\n"
  administration
end

def list_stations
  puts "\nCurrent Stations:"

  Station.all.each_with_index do |station, index|
    puts "#{index + 1}.  #{station.location}"
  end
  puts "\nEnter a number to view all stops for that station"
  user_input = gets.chomp
  current_station = Station.all[user_input.to_i - 1]
  list_lines_by_station(current_station)
end

def add_line
  puts "\nWhat color is this line? "
  print ">"
  color = gets.chomp
  line = Line.new({:color => color})
  line.save
  puts "#{line.color} has been saved!\n"
  add_stops(line)
end

def add_stops(line)
  puts "What stations does this line stop at?"
  Station.all.each_with_index do |station, index|
    puts "#{index + 1}.  #{station.location}"
  end

  puts "Enter the station number"
  line_num = gets.chomp

  current_station = Station.all[line_num.to_i - 1]
  duplicate = false
  check = DB.exec("SELECT * FROM stops WHERE station_id = '#{current_station.id}'")
    check.each do |result|
      if result['line_id'].to_i == line.id
        duplicate = true
      end
    end

  if duplicate == false
    DB.exec("INSERT INTO stops (station_id, line_id) VALUES (#{current_station.id}, #{line.id});")
  end

  puts "Do you want to add another stop? Press 'y'"
  puts "Press any other key to return to admin menu"
  user_input = gets.chomp
  case user_input
  when 'y'
    add_stops(line)
  else
    administration
  end
end

def list_lines
  puts "\nCurrent Lines:"
  Line.all.each_with_index do |line, index|
    puts "#{index + 1}.  #{line.color}"
  end
  puts "\nEnter a number to see the locations at which a line stops: "
  user_input = gets.chomp.to_i

  current_line = Line.all[user_input - 1]
  list_stops(current_line)
end

def list_stops(line)
# puts DB.exec("SELECT * From lines INNER JOIN stops ON lines.id = stops.lines_id;")
  results = DB.exec("SELECT * FROM stops WHERE line_id = #{line.id};")
  puts "#{line.color} stops at these stations:"
  results.each do |result|
    station_id = result['station_id']
    station_names = DB.exec("SELECT * FROM stations WHERE id = #{station_id};")
    station_names.each { |station| puts station['location'] }
  end
  puts "Press any key to return to main menu"
  user_input = gets.chomp
  case user_input
    when
      main_menu
  end
end

def list_lines_by_station(station)
  results = DB.exec("SELECT * FROM stops WHERE station_id = #{station.id};")
  puts "These lines run through #{station.location}:"
  results.each do |result|
    line_id = result['line_id']
    line_names = DB.exec("SELECT * FROM lines WHERE id = #{line_id};")
    line_names.each { |line| puts line['color'] }
  end
  puts "Press any key to return to main menu"
  user_input = gets.chomp
  case user_input
    when
      main_menu
  end
end

def delete
  puts "Type 's' to delete a station"
  puts "Type 'l' to delete a line"
  user_input = gets.chomp

  case user_input
  when 's'
    Station.all.each_with_index do |station, index|
      puts "#{index + 1}. #{station.location}"
    end

    puts "Type the number to delete a station"
    user_delete = gets.chomp

    current_station = Station.all[user_delete.to_i - 1]

    DB.exec("DELETE FROM stations WHERE location = '#{current_station.location}';")
    DB.exec("DELETE FROM stops WHERE station_id = #{current_station.id};")
    puts "#{current_station.location} deleted."
    administration

  when 'l'
    Line.all.each_with_index do |line, index|
      puts "#{index + 1}. #{line.color}"
    end

    puts "Enter the number to delete a line"
    user_delete = gets.chomp

    current_line = Line.all[user_delete.to_i - 1]

    DB.exec("DELETE FROM line WHERE color = '#{current_line.color}';")
    DB.exec("DELETE FROM stops WHERE line_id = #{current_line.id};")
    puts "#{current_line.color} deleted."

    administration
  end
end

def change_route

  Line.all.each_with_index do |line, index|
    puts "#{index + 1}. #{line.color}"
  end

  puts "Enter the number to change a line"
  user_change = gets.chomp

  current_line = Line.all[user_change.to_i - 1]

  Station.all.each_with_index do |station, index|
    puts "#{index + 1}. #{station.location}"
  end

  puts "Enter the number to add a station to #{current_line.color}"
  user_change = gets.chomp

  current_station = Station.all[user_change.to_i - 1]

  DB.exec("INSERT INTO stops (station_id, line_id) VALUES ('#{current_station.id}', '#{current_line.id}');")

  puts "#{current_station.location} has been added to the #{current_line.color} line!"

  administration
end

def schedule
  puts "Enter a train number to see when it will arrive: "
  train = gets.chomp
  puts "What is your station ID?: "
  station = gets.chomp

  arrival = DB.exec("SELECT time FROM times WHERE station_id = #{station} AND train_id = #{train};")
  puts "Your train will arraive at #{arrival.first['time']}"

  main_menu
end

main_menu
