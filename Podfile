platform :osx, '10.14'

target 'Song Rating' do
  use_frameworks!

  # Pods for Song Rating
  pod 'MASShortcut'
  pod 'DominantColor', :git => 'https://github.com/indragiek/DominantColor.git'
 
  target 'Song RatingTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |lib|
  lib.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET'
    end
  end
end
