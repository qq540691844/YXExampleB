#
# Be sure to run `pod lib lint YXExampleB.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YXExampleB'
  s.version          = '0.1.0'
  s.summary          = 'example example'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Description of YXExampleB.'

  s.homepage         = 'https://github.com/qq540691844/YXExampleB.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qq540691844' => '13581478122@163.com' }
  s.source           = { :git => "https://github.com/qq540691844/YXExampleB.git", :tag => '0.1.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YXExampleB/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YXExampleB' => ['YXExampleB/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreBluetooth'
  s.dependency 'BabyBluetooth','~> 0.7.0'
end
