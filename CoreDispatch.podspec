Pod::Spec.new do |s|
  s.name = 'CoreDispatch'

  s.version = '1.0.0'
  
  s.homepage = "https://github.com/naftaly/CoreDispatch"
  s.source = { :git => "https://github.com/naftaly/CoreDispatch.git", :tag => s.version }
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Simple wrapper around GCD.'

  s.social_media_url = 'https://twitter.com/naftaly'
  s.authors  = { 'Alexander Cohen' => 'naftaly@me.com' }

  s.requires_arc = true

  s.ios.deployment_target = '9.0'
	
  s.source_files = [ 'CoreDispatch/*.h', 'CoreDispatch/*.m' ]
  s.public_header_files = [ 'CoreDispatch/*.h' ]
end
