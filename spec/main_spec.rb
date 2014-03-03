require './dby.rb'

describe DBY::DBYConfig, '#initialize' do
  it 'determines where the configuration file should go.' do
    config = DBY::DBYConfig.new
    config.initialize.should eq("#{Dir.home}/.dby.conf")
  end
end
describe DBY::Package, '#install' do
  it 'is an un-implemented function, and is useless at this time' do
    package = DBY::Package.new
    package.install.should eq('E1')
  end
end
