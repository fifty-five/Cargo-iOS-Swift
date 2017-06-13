begin
  require File.expand_path('./scripts/build.rb')
end


Pod::Spec.new do |s|
  s.name             = "Cargo-Swift"
  s.version          = "3.0.0"
  s.summary          = "Cargo makes it easier to track your mobile app."

  s.description      = <<-DESC
  Cargo is a tool developed by fifty-five. It allows to quickly and easily integrate third-party analytics SDKs through Google Tag Manager.
  With Google Tag Manager (GTM), developers are able to change configuration values in their mobile applications using the GTM interface without having to rebuild and resubmit app binaries to marketplaces.
                       DESC

  s.homepage         = "https://github.com/fifty-five/Cargo-iOS-Swift"
  s.license          = 'MIT'
  s.author           = { "Julien" => "julien.gil@fifty-five.com" }
  s.source           = { :git => "https://github.com/fifty-five/Cargo-iOS-Swift.git", :tag => "v#{s.version.to_s}" }
  s.documentation_url = 'https://github.com/fifty-five/Cargo-iOS-Swift/wiki'
  s.social_media_url = 'https://twitter.com/55FiftyFive55'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.subspec 'Core' do |ss|
    ss.source_files = "Cargo/Core/**/*.{m, h, swift}"
    ss.platform = :ios, '8.0'
    s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => "CARGO_VERSION=#{s.version}" }
    s.dependency 'GoogleTagManager', '~> 6.0.0'
  end

  Build.subspecs.each do |a|
    s.subspec a.name do |ss|
      ss.prefix_header_contents = "#define USE_CARGO_#{a.name.upcase} 1"

      ss.platform = :ios, '8.0'
      ss.ios.source_files = "Cargo/Handlers/#{a.name}/*.swift"
      ss.dependency 'Cargo/Core'

      (a.dependencies || []).each do |d|
        if d.version
          ss.dependency d.name, d.version
        else
          ss.dependency d.name
        end
      end
    end
  end

end