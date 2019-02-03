Gem::Specification.new do |s|
  s.name = 'pky'
  s.version = '0.1'
  s.summary = 'Your favourite PKI generation tool'
  s.description = 'Define a private key infrastructure in YAML'
  s.authors = ['Anshul Sirur']
  s.email = 'vixus0@gmail.com'
  s.files = Dir['lib/{,**/}*.rb']
  s.homepage = 'https://github.com/vixus0/pky.gem'
  s.license = 'WTFPL'

  s.executables << 'pky'
end
