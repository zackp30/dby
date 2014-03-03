require './dby.rb'

describe DBY::Package, '#install' do
  it 'is an un-implemented function, and is useless at this time' do
    package = DBY::Package.new
    package.install.should eq('E1')
  end
end
