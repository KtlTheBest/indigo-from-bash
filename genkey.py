#!/usr/bin/env python3
from cryptography.fernet import Fernet as fr

k = fr.generate_key()
print(k.decode())
