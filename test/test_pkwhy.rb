require 'minitest/autorun'
require 'openssl'
require 'yaml'
require 'pky'

class TestPky < Minitest::Test
  def setup
    @hash = YAML.load <<~YAML
      name: root_ca
      subject: Root CA
      certs:
        - name: inter_ca
          certs:
            - child
    YAML
    @certs = Pky.traverse(@hash)
  end

  def test_sanity
    assert_equal(3, @certs.size)
  end

  def test_parents
    inter = @certs.fetch('root_ca/inter_ca')
    child = @certs.fetch('root_ca/inter_ca/child')
    assert_equal('root_ca', inter.parent.name)
    assert_equal('inter_ca', child.parent.name)
  end

  def test_chain
    root  = @certs.fetch('root_ca')
    inter = @certs.fetch('root_ca/inter_ca')
    child = @certs.fetch('root_ca/inter_ca/child')

    store = OpenSSL::X509::Store.new
    store.add_cert(root.cert)
    store.add_cert(inter.cert)

    assert(store.verify(child.cert))
  end
end
