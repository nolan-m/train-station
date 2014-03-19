require 'train'
require 'line'
require 'station'
require 'rspec'
require 'pg'

DB = PG.connect({:dbname => 'train_system_test'})
RSpec.configure do |config|
  config.after(:each) do
    DB.exec("DELETE FROM trains *;")
    DB.exec("DELETE FROM stations *;")
    DB.exec("DELETE FROM lines *;")
  end
end

describe 'Train' do
  it 'initializes a train object with a line' do
    test_train  = Train.new({:line => "Green"})
    test_train.should be_an_instance_of Train
    test_train.line.should eq "Green"
  end

  describe 'save' do
    it 'saves a train objects attributes to the database' do
      test_train = Train.new({:line => "Green"})
      test_train.save
      Train.all.should eq [test_train]
    end
  end

  describe '.all' do
    it 'start as an empty array' do
      Train.all.should eq []
    end
  end
end

describe 'Station' do
  it 'initializes a station object with a location' do
    test_station  = Station.new({:location => "Burnside"})
    test_station.should be_an_instance_of Station
    test_station.location.should eq "Burnside"
  end

  describe 'save' do
    it 'saves a station objects attributes to the database' do
      test_station = Station.new({:location => "Burnside"})
      test_station.save
      Station.all.should eq [test_station]
    end
  end

  describe '.all' do
    it 'start as an empty array' do
      Station.all.should eq []
    end
  end
  it 'returns its id after saving' do
    test_station = Station.new({:location => "Washington"})
    test_station.save
    test_station.id.should be_an_instance_of Fixnum
  end
end

describe 'Line' do
  it 'initializes a line object with a color' do
    test_line  = Line.new({:color => "Green"})
    test_line.should be_an_instance_of Line
    test_line.color.should eq "Green"
  end

  describe 'save' do
    it 'saves a line objects attributes to the database' do
      test_line = Line.new({:color => "Green"})
      test_line.save
      Line.all.should eq [test_line]
    end
  end

  describe '.all' do
    it 'start as an empty array' do
      Line.all.should eq []
    end
  end
end
