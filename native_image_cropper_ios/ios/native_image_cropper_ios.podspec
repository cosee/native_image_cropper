#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_image_cropper_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_image_cropper_ios'
  s.version          = '0.0.1'
  s.summary          = 'the ios implementation of native_image_cropper.'
  s.description      = <<-DESC
the ios implementation of native_image_cropper. it allows you to crop an image to a circle and a rectangle.
                       DESC
  s.homepage         = 'https://pub.dev/publishers/cosee.biz/packages'
  s.license          = { :file => '../license' }
  s.author           = { 'cosee' => 'mobile.cosee@gmail.com' }
  s.source           = { :git => 'https://github.com/cosee/native_image_cropper.git' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
