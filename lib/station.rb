class Station

  attr_reader(:location, :id)

  def initialize(attributes)
    @location = attributes[:location]
    @id = attributes[:id]
  end

  def self.all
    results = DB.exec("SELECT * FROM stations;")
    stations = []
    results.each do |result|
      location = result['location']
      id = result['id']
      stations << Station.new({:location => location, :id => id})
    end
    stations
  end

  def save
    check = DB.exec("SELECT * FROM stations WHERE location = '#{@location}';")
    if check.first == nil
      results = DB.exec("INSERT INTO stations (location) VALUES ('#{@location}') RETURNING id;")
      @id = results.first['id'].to_i
    else
      @id = check.first['id'].to_i
    end
  end

  def ==(station)
    station.location == self.location
  end
end

