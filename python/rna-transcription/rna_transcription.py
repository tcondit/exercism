'''
Write a program that, given a DNA strand, returns its RNA complement (per RNA
transcription).

Both DNA and RNA strands are a sequence of nucleotides.

The four nucleotides found in DNA are adenine (**A**), cytosine (**C**),
guanine (**G**) and thymine (**T**).

The four nucleotides found in RNA are adenine (**A**), cytosine (**C**),
guanine (**G**) and uracil (**U**).

Given a DNA strand, its transcribed RNA strand is formed by replacing each
nucleotide with its complement:

* `G` -> `C`
* `C` -> `G`
* `T` -> `A`
* `A` -> `U`
'''

# NB: May raise a KeyError, will not handle it
def dna_nucleotide_to_rna(dna):
    dna_rna_dict = { 'G': 'C', 'C': 'G', 'T': 'A', 'A': 'U' }
    return dna_rna_dict[dna]

def to_rna(dna):
    rna = ''
    for nucleotide in dna:
        try:
            rna += dna_nucleotide_to_rna(nucleotide)
        except KeyError:
            return ''
    return rna

if __name__ == '__main__':
    print(to_rna('CGGATGATTACA'))
