# Syntax follows SageMath interpreter
from venv import create
import gurobipy
from typing import List
from sage.crypto.block_cipher.present import PRESENT, PRESENT_KS
from sage.misc.prandom import choice
from random import Random

# test if file runs properly on Sage, with load()
# print(3^5)    # 3 raise to 5, not 3 xor 5

present=PRESENT()
rand= Random()
r_key= rand.randint(0,2^80-1)
test_encrypt= present.encrypt(plaintext=0, key=r_key).hex()
# print(test_encrypt)
ks= PRESENT_KS()
print(hex(r_key))
print(r_key)
ps= [k.hex() for k in ks(r_key)]
print(ps[0])


# Modelling PRESENT-80
# Maintain 64-bit data in a list
data= [0]*64

# sBoxLayer
SBOX= [0xC, 5, 6, 0xB, 9, 0, 0xA, 0xD, 3, 0xE, 0xF, 8, 4, 7, 1, 2]  # index= original 4-bit word
INV_SBOX= [SBOX.index(i) for i in range(len(SBOX))]

#pLayer
PBOX= [(16*i)%63 for i in range(63)] + [63]
INV_PBOX= [PBOX.index(i) for i in range(64)]