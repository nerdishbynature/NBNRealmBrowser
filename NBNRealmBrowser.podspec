Pod::Spec.new do |s|
  s.name             = "NBNRealmBrowser"
  s.version          = "0.1.0"
  s.summary          = "NBNRealmBrowser is the iOS companion to the Realm Browser for Mac."
  s.description      = <<-DESC
                        NBNRealmBrowser is the iOS companion to the
                        Realm Browser for Mac.
                        It displays all information for your current
                        Realm for debugging purposes.
                       DESC
  s.homepage         = "https://github.com/nerdishbynature/NBNRealmBrowser"
  s.license          = 'MIT'
  s.author           = { "Piet Brauer" => "piet@nerdishbynature.com" }
  s.source           = { :git => "https://github.com/nerdishbynature/NBNRealmBrowser.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/pietbrauer'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'
  s.dependency 'Realm', '~> 0.85'
end
