def do_thing(*args, &job)
  job.call(args)
end

do_thing(:blah) { |x| x.to_s }
# do_thing :blah do |x|
#   puts x.to_s
# end

{
  "name" => "someState",
  "enterState" => Proc.new { |args| puts args },
  
  "exitState" => Proc.new { |args| puts args }
}

class State
  def initialize
    
  end
end
