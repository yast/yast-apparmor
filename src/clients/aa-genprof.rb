require 'apparmor/genprof.rb'

gp = AppArmor::GenProf.new
gp.execute unless gp.nil?

