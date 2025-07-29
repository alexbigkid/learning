#!/bin/bash

python3 shadow.py \
--endpoint $AWS_IOT_ENDPOINT \
--cert $AWS_IOT_CERTIFICATE_FILE \
--key $AWS_IOT_PRIVATE_KEY_FILE \
--root-ca $AWS_IOT_AMAZON_ROOT_CA1_FILE \
--thing-name $AWS_IOT_LPS_THING_NAME \
--shadow-property $AWS_IOT_THING_SHADOW_PROPERTY

