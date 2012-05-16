require 'rubygems'
require Dir.pwd()+'/stativus.rb'
statechart = Stativus::Statechart.new

class Book < Stativus::State
  has_concurrent_substates true
  def enter
    puts "hello"
  end
end
statechart.add_state(Book)

class Document < Stativus::State
  parent_state Book
end
statechart.add_state(Document)
statechart.goto_state("Book", "default")




