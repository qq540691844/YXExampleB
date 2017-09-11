Pod::Spec.new do |s|
  s.name = "YXExampleB"
  s.version = "0.1.0"
  s.summary = "example example"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"qq540691844"=>"13581478122@163.com"}
  s.homepage = "https://github.com/qq540691844/YXExampleB.git"
  s.description = "Description of YXExampleB."
  s.frameworks = "CoreBluetooth"
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/YXExampleB.framework'
end
