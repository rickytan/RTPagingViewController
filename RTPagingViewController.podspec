Pod::Spec.new do |s|
  s.name         = 'RTPagingViewController'
  s.version      = '1.0.1'
  s.authors      = { 'Ricky Tan' => 'ricky.tan.xin@gmail.com' }
  s.homepage     = 'https://github.com/rickytan/RTPagingViewController'
  s.platform     = :ios
  s.summary      = 'A simple to use Paging View Controller, a Android ViewPager Implimetation'
  s.source       = { :git => 'https://github.com/rickytan/RTPagingViewController.git', :tag => s.version.to_s }
  s.license      = 'MIT'
  s.frameworks   = 'UIKit'
  s.source_files = 'Classes'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.social_media_url = 'http://rickytan.cn'
end