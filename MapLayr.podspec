Pod::Spec.new do |spec|
	spec.name                = "MapLayr"
	spec.version             = "0.10.2"
	spec.summary             = "High performance mapping for venues."
	spec.homepage            = "https://maplayr.com"
	spec.author              = "AppLayr"
	
	spec.platform            = :ios, "13.0"
	
	spec.source              = { :git => "git@github.com:applayr/maplayr-ios.git", :tag => "v#{spec.version}" }
	spec.source_files        = "Sources/MapLayr"
	
	spec.vendored_frameworks = ["MapLayrInternal.xcframework", "MapGeometry.xcframework"]
	
	spec.prepare_command     = <<-CMD
	                                rm -r MapLayrInternal.xcframework.zip MapLayrInternal.xcframework MapGeometry.xcframework.zip MapGeometry.xcframework || true
	                                
	                                curl -L -o MapLayrInternal.xcframework.zip "https://cdn.attractions.io/frameworks/maplayr-ios/v0.10.1/MapLayrInternal.xcframework.zip"
	                                unzip MapLayrInternal.xcframework.zip
                                    rm MapLayrInternal.xcframework.zip
	                                
	                                curl -L -o MapGeometry.xcframework.zip "https://cdn.attractions.io/frameworks/map-geometry-swift/v1.3.0/MapGeometry.xcframework.zip"
	                                unzip MapGeometry.xcframework.zip
	                                rm MapGeometry.xcframework.zip
	                              CMD
	
	spec.dependency          "ZIPFoundation", "~> 0.9.16"
end
