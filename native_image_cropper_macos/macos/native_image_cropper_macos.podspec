#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_image_cropper_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_image_cropper_macos'
  s.version          = '0.1.0'
  s.summary          = 'The MacOS implementation of native_image_cropper.'
  s.description      = <<-DESC
The MacOS implementation of native_image_cropper. It allows you to crop an image to an oval and a rectangle.
                       DESC
  s.homepage         = 'https://pub.dev/publishers/cosee.biz/packages'
  s.license          = { :type => 'BSD-3', :file => '../LICENSE' }
  s.author           = { 'cosee GmbH' => 'mobile.cosee@gmail.com' }
  s.source           = { :http => 'https://github.com/cosee/native_image_cropper/tree/main/native_image_cropper_ios' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.7'
end
