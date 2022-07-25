from random import Random
from time import time
rand= Random()

#STANDARD

SBOX= [0xe, 0x4, 0xd, 0x1,0x2, 0xf, 0xb, 0x8, 0x3, 0xa, 0x6, 0xc, 0x5, 0x9, 0x0, 0x7]
INV_SBOX= [SBOX.index(i) for i in range(16)]

PBOX= [((4*i) %15) for i in range(15)] + [15]
INV_PBOX= [PBOX.index(i) for i in range(16)]

# create_new_key= lambda key, round: key^^round

tobits= lambda x: [*map(int, format(x, "016b"))][::-1]
frombits= lambda y: sum(y[i]*(2^i) for i in range(len(y)))

def encrypt(plaintext, key): 
    cipher= plaintext
    for round in range(4):      # use 1 round less for probabilistic test of differential characteristic
        cipher ^^= key^^round 
        # print(hex(cipher))

        b= tobits(cipher)
        for j in range(0, len(b), 4): b[j:j+4]= tobits(SBOX[frombits(b[j:j+4])])[:4]
        # print(hex(frombits(b)))

        temp= [[]]*16
        for i in range(len(b)): temp[PBOX[i]]= b[i]
        b= temp
        cipher= frombits(b)
        # print(hex(cipher))
    
    cipher ^^= key^^4

    return cipher

# test_entry= 0x1234
# test_cipher= encrypt(test_entry, test_key)
# print(hex(test_cipher))


# brute force differential attack

test_key= rand.randint(0, 0xffff)
input_d= 0x0b00
e_output_d= 0x0606        # s-box 2 and 4, from msb
input_d1= 0xa0a0
e_output_d1= 0x8088      # s-box 1, 3, 4, from msb

# probabilistic test with actual key
# start_time= time()
# x= set(); m=[0]*2^8
# for entry in range(15000):
#     x1= rand.randint(0,0xffff)
#     while (x1 in x): x1= rand.randint(0,0xffff)
#     x2= x1^^input_d
#     x.add(x1); x.add(x2); 

#     y1= encrypt(x1, test_key)
#     y2= encrypt(x2, test_key)
    
#     y_diff= tobits(y1^^y2)
#     cha= y_diff[0:4]+y_diff[8:12]
#     m[frombits(cha)]+=1

# print(hex(m.index(max(m))), (max(m)/15000).n())
# print(m)
# print(time()- start_time)

# attack
start_time= time()
x= set(); y=[0]*2^8

for entry in range(1000): 
    x1= rand.randint(0, 0xffff)
    while x1 in x: x1= rand.randint(0, 0xffff)
    x2= x1^^input_d
    x.add(x1); x.add(x2); 
    
    y1= encrypt(x1, test_key)
    y2= encrypt(x2, test_key)

    for out in range(2^8):
        temp= [[]]*16
        out_key= tobits(out); out_b= []; 
        for i in range(len(out_key)): out_b+= [out_key[i]]+ [0]     # key-bits fitted due to choice of differential / s-boxes
        out_key= frombits(out_b)

        y1b= tobits(y1^^out_key)
        for i in range(len(y1b)): temp[INV_PBOX[i]]= y1b[i]
        for j in range(0, len(temp), 4): temp[j:j+4]= tobits(INV_SBOX[frombits(temp[j:j+4])])[:4]
        y1b= frombits(temp)

        y2b= tobits(y2^^out_key)
        for i in range(len(y2b)): temp[INV_PBOX[i]]= y2b[i]
        for j in range(0, len(temp), 4): temp[j:j+4]= tobits(INV_SBOX[frombits(temp[j:j+4])])[:4]
        y2b= frombits(temp)

        y_diff= tobits(y1b^^y2b)
        if frombits(y_diff)== e_output_d: y[out]+=1

obtained_bits= []
bt= tobits(y.index(max(y))^^2)
for i in range(8): obtained_bits+= [bt[i]] +[0]

x= set(); y= [0]*2^8; 
for entry in range(1000):
    x1= rand.randint(0, 0xffff)
    while x1 in x: x1= rand.randint(0, 0xffff)
    x2= x1 ^^ input_d1
    x.add(x1); x.add(x2); 

    y1= encrypt(x1, test_key)
    y2= encrypt(x2, test_key)

    for out in range(2^8):
        temp= [[]]*16
        out_key= tobits(out); out_b= []; 
        for i in range(8): out_b+= [obtained_bits[2*i]]+ [out_key[i]]
        out_key= frombits(out_b) ^^4

        y1b= tobits(y1^^out_key)
        for i in range(len(y1b)): temp[INV_PBOX[i]]= y1b[i]
        for j in range(0, len(temp), 4): temp[j:j+4]= tobits(INV_SBOX[frombits(temp[j:j+4])])[:4]
        y1b= frombits(temp)

        y2b= tobits(y2^^out_key)
        for i in range(len(y2b)): temp[INV_PBOX[i]]= y2b[i]
        for j in range(0, len(temp), 4): temp[j:j+4]= tobits(INV_SBOX[frombits(temp[j:j+4])])[:4]
        y2b= frombits(temp)

        y_diff= tobits(y1b^^y2b)
        if frombits(y_diff)== e_output_d1: y[out]+=1

bt= tobits(y.index(max(y)))
for i in range(8): obtained_bits[2*i+1]= bt[i]      # remaining bits
obtained_key= frombits(obtained_bits)

print(hex(obtained_key), hex(test_key))
print(time()-start_time)
# Success with 1000 pairs at 45s


# Automatic Search
# Forming the MILP