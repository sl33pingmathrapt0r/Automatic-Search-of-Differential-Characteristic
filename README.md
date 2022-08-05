# Automatic Search of Differential Characteristic
 To automate the search of differential characteristics in symmetric key ciphers

Notebooks for viewing: 
1. simple_spn.ipynb
   - An attempt to attack a very simple SPN cipher, using a known differential characteristic. 
   - An attampt to form MILP based on the convex hull of the S-Box

2. present_diff-attack_milp.ipynb
   - Based on the insights of "simple_spn.ipynb", attempt MILP on PRESENT-80 (up to 6 rounds)
   - (TODO) inclusion of Matsui's bound in MILP constraints
   - (TODO) using greedy algorithm to choose constraints

Poster presented for NTU's Odyssey Research Programme 2022. 
