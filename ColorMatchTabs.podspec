Pod::Spec.new do |s|

  s.name             = "ColorMatchTabs"
  s.version          = "2.0.1"
  s.summary          = "UI animation concept fo review apps."

  s.homepage         = "https://github.com/Yalantis/ColorMatchTabs"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "Yalantis"
  s.social_media_url = "http://twitter.com/yalantis"
  
  s.platform         = :ios, "9.0"
  s.source           = { :git => "https://github.com/Yalantis/ColorMatchTabs.git", :tag => s.version }

  s.source_files     = "ColorMatchTabs/Classes/**/*.{swift}"
  s.resources        = "ColorMatchTabs/Resources/MenuAssets.xcassets"

end
