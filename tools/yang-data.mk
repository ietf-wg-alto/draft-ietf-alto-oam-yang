FEATURES=-F ietf-alto:alto-server \
	-F ietf-http-server:client-auth-supported,local-users-supported,basic-auth \
	-F ietf-restconf-client:listen,tcp-listen \
	-F ietf-subscribed-notifications:xpath \
	-F ietf-crypto-types:cleartext-passwords,hidden-private-keys \
	-F ietf-keystore:inline-definitions-supported \
	-F ietf-truststore:inline-definitions-supported \
	-F ietf-tls-client:client-ident-raw-public-key,server-auth-raw-public-key \
	-F ietf-tls-server:server-ident-raw-public-key

YANGCACHE ?= ~/.ietf-yang-validator
FULL_JSON_MODEL ?= examples/full-model-usage.json

.PHONY: yanglint-data-validate

yanglint-data-validate:
	yanglint $(FEATURES) -p $(YANGCACHE) -p $(YANGDIR) $(YANGDIR)/*.yang $(FULL_JSON_MODEL)
