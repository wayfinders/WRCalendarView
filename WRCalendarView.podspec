#
# Be sure to run `pod lib lint WRCalendarView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WRCalendarView'
  s.version          = '1.0.0'
  s.summary          = 'Calendar Day and Week View for iOS'
  s.description      = 'Calendar Day and Week View for iOS'
  s.homepage         = 'https://github.com/wayfinders/WRCalendarView'
  s.screenshots      = ['https://github.com/wayfinders/WRCalendarView/blob/master/Example/Screenshots/1.png',
                        '(https://github.com/wayfinders/WRCalendarView/blob/master/Example/Screenshots/1.gif']
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wayfinder' => 'wayfinder12@gmail.com' }
  s.source           = { :git => 'https://github.com/wayfinders/WRCalendarView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'WRCalendarView/**/*'
  
  s.resource_bundles = {
    'WRCalendarView' => ['WRCalendarView/**/*.{storyboard,xib}']
  }
  s.dependency 'DateToolsSwift'
end
