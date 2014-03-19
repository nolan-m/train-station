class Train
  attr_reader(:line, :time)

  def initialize(attributes)
    @line = attributes[:line]
    @time = attributes[:time]
  end

  def self.all
    results = DB.exec("SELECT * FROM trains;")
    trains = []
    results.each do |result|
      line = result['line']
      time = result['time']
      trains << Train.new({:line => line})
    end
    trains
  end

  def save
    DB.exec("INSERT INTO trains (line, time) VALUES ('#{@line}', '#{@time}');")
  end

  def ==(train)
    train.line == self.line
  end
end
