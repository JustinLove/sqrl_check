require 'sqrl/check/server'

desc "run server test suite"
task :test, [:target_url, :signed_cert] do |t, args|
  SQRL::Check::Server.autorun(args)
end
