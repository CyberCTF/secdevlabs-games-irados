#!/bin/sh
# A new player signs up, logs in and tries a wrong coupon: the shop just says it is invalid.
set -e
jar=$(mktemp)
base=http://app:10010
user="probe$$"
token() { curl -fsS -c "$jar" -b "$jar" "$base/$1" | sed -n 's/.*name="_csrf_token" type="hidden" value="\([^"]*\)".*/\1/p' | head -n 1; }
t=$(token register)
curl -fsS -o /dev/null -c "$jar" -b "$jar" --data "_csrf_token=$t&username=$user&password1=probe-pass&password2=probe-pass" "$base/register"
t=$(token login)
curl -fsS -o /dev/null -c "$jar" -b "$jar" --data "_csrf_token=$t&username=$user&password=probe-pass" "$base/login"
t=$(token coupon)
curl -fsS -c "$jar" -b "$jar" --data "_csrf_token=$t&coupon=zzzzz" "$base/coupon" | grep -q 'Cupom invalido'
