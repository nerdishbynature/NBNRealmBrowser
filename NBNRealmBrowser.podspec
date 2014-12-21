Pod::Spec.new do |s|
  s.name             = "NBNRealmBrowser"
  s.version          = "0.1.0"
  s.summary          = "A short description of NBNRealmBrowser."
  s.description      = <<-DESC
                       An optional longer description of NBNRealmBrowser

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
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
