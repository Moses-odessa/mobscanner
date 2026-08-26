#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
# Vendored from tesseract_ocr 0.5.0. Local changes vs upstream:
#
#   * Dropped `s.dependency 'SwiftyTesseract401'`. That pod is not published on
#     CocoaPods trunk — upstream shipped a private podspec beside this one and
#     expected it to resolve, which it never can, so `pod install` always failed
#     with "Unable to find a specification for SwiftyTesseract401".
#     Nothing actually needed it: the iOS implementation in
#     Classes/SwiftTesseractOcrPlugin.swift does all its OCR through Apple's
#     Vision framework (VNRecognizeTextRequest), and no source file imports
#     SwiftyTesseract. Every reference sat behind a `#if canImport(...)` guard
#     that was always false.
#   * Dropped OTHER_SWIFT_FLAGS=-DUSE_SWIFTY_TESSERACT along with it; the define
#     gated nothing (the guards test for a module, not this flag).
#   * Deleted the orphaned SwiftyTesseract401.podspec and libtesseract.podspec,
#     the plugin's own example Podfile, and a .swift.bak backup.
#
# Vision has first-class Russian and Ukrainian recognition, which is why this
# platform never used Tesseract to begin with. Android is the Tesseract side.
#
Pod::Spec.new do |s|
  s.name             = 'tesseract_ocr'
  s.version          = '0.5.0'
  s.summary          = 'Tesseract OCR 4 Flutter'
  s.description      = <<-DESC
Tesseract 4 adds a new neural net (LSTM) based OCR engine which is focused on line recognition. It has unicode (UTF-8) support, and can recognize more than 100 languages.
                       DESC
  s.homepage         = 'https://paratoner.io'
  s.license          = { :file => '../LICENSE',:type => 'BSD' }
  s.author           = { 'Ahmet TOK' => 'arny@paratoner.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/*.{h,m,mm,swift}'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.3'
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.3'
  }
  s.frameworks = 'Foundation', 'UIKit', 'Vision'
end
