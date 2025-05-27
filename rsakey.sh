#!/bin/bash

#generate private key
openssl genrsa -out automotive_mcu_private.pem 4096

#extra public key
openssl rsa -in automotive_mcu_private.pem -pubout -out automotive_mcu_public.pem
