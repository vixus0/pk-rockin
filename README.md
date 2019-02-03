# pky

## What

Sometimes you just need a big pile of certificate chain to trip up on and it's a pain to generate manually.

Given a YAML file that looks like this:

```yaml
name: root_ca
subject: Root CA
certs:
  - name: inter_ca
    certs:
      - child
```

`pky` will create a tree of certs and keys:

```
example
├── root_ca
│   ├── inter_ca
│   │   ├── child.crt.pem
│   │   └── child.key.pem
│   ├── inter_ca.crt.pem
│   └── inter_ca.key.pem
├── root_ca.crt.pem
└── root_ca.key.pem
```

## Usage

```
gem install pky
pky certs.yml certs/
```

_But why?_ Good question.
