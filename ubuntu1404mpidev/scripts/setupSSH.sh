#!/bin/bash

mkdir -p /root/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8lRAN6cVJo+mbbWco0ATbKvsqztEWeBrofl9k+W1PgQbF0OcQUQu9Kus3DxGorpj/p9iSywT6rsJSuHboEAaRn2Ogg+/qIcl+vfxqwUtfExgbonq5jli/U3bVRWJ/EJi2ZPbrjWKSVrkP1MeF2I+1wLKktj2IFHb9TF2PIOzpNRhLnJRgihRHTN+OxBI4gGwulu4PZTK5G2MErYJfA9zv7fO0U6JwoDrawck3xbbuYWBi5F5gD+0yTOWcX2iDU6kNtOgAAKlgGgjUBJA8d40+s43o2j/7o+JLHoMJzKZOxR9FBUnBOLBrpVtJdF2WUHurJroZ2xKlo7HLNHtnNVqV root@92edccd90cd6" >> /root/.ssh/authorized_keys
chmod og-rwx /root/.ssh/authorized_keys

/usr/sbin/sshd -p 2222
