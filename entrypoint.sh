#!/bin/bash
bitcoind -testnet=4 -server -txindex -zmqpubhashblock=tcp://0.0.0.0:28332 &
/opt/ckpool/ckpool --config /opt/ckpool/conf/ckpool.conf

