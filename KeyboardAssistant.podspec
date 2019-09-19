Pod::Spec.new do |s|

  s.platform     = :ios, "9.0"

  s.name         = "KeyboardAssistant"
  s.version      = "1.1.0"
  s.license      = "MIT"

  s.homepage     = "https://github.com/levieggert/KeyboardAssistant"
  s.author       = { "levieggert" => "levi.eggert@gmail.com" }
  s.summary      = "Module for positioning views above the keyboard."
  s.description  = "A swift library for positioning UITextField, UITextView, and UIView objects above the keyboard.  Supports customizable keyboard navigation with auto and manual positioning."

  s.source       = { :git => "https://github.com/levieggert/KeyboardAssistant.git", :tag => "#{s.version}" }

  s.source_files = 'Source/*.swift'
  s.resources = 'Resources/*.*'
  s.swift_version = '5.0'
end
