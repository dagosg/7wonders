#!/bin/bash
openssl genrsa -out ./server-private.pem 1024
openssl req -new -x509 -key ./server-private.pem -out ./server-public.pem -days 365 -config ./openssl.cfg

