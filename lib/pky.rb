require 'openssl'
require 'ssl'

class Pky
  def self.traverse(node, parent = nil)
    case node
    when Array
      node.reduce(Hash.new) { |h, n| h.update(self.traverse(n, parent)) }
    when Hash
      name = node.fetch('name')
      subject = node.fetch('subject', name)
      subcerts = node['certs']
      is_ca = !subcerts.nil?
      cert = generate_cert(name, subject, is_ca, parent, node['expiry'])
      if is_ca
        { cert.path => cert }.update(self.traverse(subcerts, cert))
      else
        { cert.path => cert }
      end
    when String
      cert = generate_cert(node, nil, parent.nil?, parent)
      { cert.path => cert }
    end
  end

  class CertKey
    attr_reader :name, :cert, :key, :parent
    attr_accessor :nchild

    def initialize(name, cert, key, parent = nil)
      @name = name
      @cert = cert
      @key = key
      @parent = parent
      @nchild = 0
    end

    def path
      parent.nil? ? name : File.join(parent.path, name)
    end

    def children?
      nchild > 0
    end
  end

  def self.generate_cert(name, subject = nil, ca = false, parent = nil, expiry = nil)
    key = SSL.create_key
    cert = SSL.create_certificate(key, "/CN=#{subject || name}", expiry)
    issuer_cert = parent&.cert
    signing_key = parent&.key || key
    if ca
      SSL.ca_certificate(cert, issuer_cert)
      SSL.sign_certificate(cert, signing_key)
    else
      abort "[ERROR] issuer for #{name} was nil" if parent.nil?
      SSL.issue_certificate(cert, issuer_cert)
      SSL.sign_certificate(cert, signing_key)
      parent.nchild += 1
    end
    CertKey.new(name, cert, key, parent)
  end
end
