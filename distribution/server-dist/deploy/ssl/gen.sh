openssl pkcs12 -export -in cert.crt -inkey key.pem \
               -out cert.p12 -name keycloak \
               -CAfile CA_G2.crt -caname CA_G2
