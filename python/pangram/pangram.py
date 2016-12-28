import string


def is_pangram(sentence=''):
    alphabet = string.ascii_lowercase

    for s in sentence.lower():
        if s in alphabet:
            alphabet_new = alphabet.replace(s, '')
            alphabet = alphabet_new
    return not alphabet
