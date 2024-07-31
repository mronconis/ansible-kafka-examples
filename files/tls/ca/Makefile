.PHONY: ca
default: ca ;

clean:
	rm -f index.*
	rm -f serial.*
	rm -f *.crt
	rm -f *.csr
	rm -f *.key
	rm -f *.pem
	rm -f ../certs/*.crt
	rm -f ../certs/*.pem
	rm -f ../certs/*.key
	rm -f ../certs/*.p12

serial.txt:
	echo 01 > serial.txt

index.txt:
	touch index.txt

ca: clean serial.txt index.txt
	openssl req -x509 \
	  	-config openssl.cnf \
		-newkey rsa:4096 \
		-nodes \
		-keyout ca.key \
		-out ca.crt \
		-outform PEM \
		-subj '/C=IT/ST=RM/L=Rome/O=redhat.com/OU=Consulting/CN=kafka-ca/'
	
	cp ca.crt ../certs

%.server.cert:
	openssl req -config openssl-req.cnf \
		-newkey rsa:2048 -nodes -days 365000 \
		-passout pass:123456 \
		-subj '/C=IT/ST=RM/L=Rome/O=redhat.com/OU=Consulting/CN=kafka-$*/' \
		-keyout ../certs/$*.key \
		-out $*.csr

	openssl ca -config openssl.cnf \
		-policy signing_policy \
		-extensions signing_req \
		-out ../certs/$*.pem -batch \
		-infiles $*.csr

	openssl pkcs12 -export -out ../certs/$*.p12 \
		-password pass:123456 \
		-inkey ../certs/$*.key \
		-in ../certs/$*.pem \
		-name "kafka-$*"

install: zk.server.cert kafka.server.cert
