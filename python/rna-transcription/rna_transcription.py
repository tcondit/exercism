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
