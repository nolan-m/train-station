class Line

  attr_reader(:color, :id)

  def initialize(attributes)
    @color = attributes[:color]
    @id = attributes[:id]
  end

  def self.all
    results = DB.exec("SELECT * FROM lines;")
    lines = []
    results.each do |result|
      color = result['color']
      id = result['id']
      lines << Line.new({:color => color, :id => id})
    end
    lines
  end

  def save
    check = DB.exec("SELECT * FROM lines WHERE color = '#{@color}';")
    if check.first == nil
      results = DB.exec("INSERT INTO lines (color) VALUES ('#{@color}') RETURNING id;")
      @id = results.first['id'].to_i
    else
      @id = check.first['id'].to_i
    end
  end

  def ==(line)
    line.color == self.color
  end
end
