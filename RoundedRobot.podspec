#
# Be sure to run `pod lib lint RoundedRobot.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RoundedRobot"
  s.version          = "0.5.8"
  s.summary          = "The world's simplest networking / core-data library."
  s.description      = <<-DESC
                       ROBot solves two problems.
                       * Making REST API calls easy
                       * Automatic sync'ing of REST API calls to your database
                       DESC
  s.homepage         = "https://github.com/Rounded/ROBot"
  s.license          = 'MIT'
  s.author           = { "Heather Spenenger" => "hs@roundedco.com" }
  s.source           = { :git => "https://github.com/Rounded/ROBot.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/roundedco'

  s.platform     = :ios, '6.1'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ROBot' => ['Pod/Assets/*.png']
  }

end
