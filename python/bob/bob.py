import string

def hey(what):
    what = what.strip()
    what_upper = what.strip().upper()

    print(what, what_upper)

    if what == '':
        return 'Fine. Be that way!' 

    # Both assertions currently return 'Whoa, chill out!'
    #
    # self.assertEqual('Whatever.', bob.hey('1, 2, 3')) -> fail
    # self.assertEqual('Sure.', bob.hey('4?'))          -> fail

    elif what == what_upper:
        return 'Whoa, chill out!'

    elif what.endswith('?'):
        return 'Sure.'
    else:
        return 'Whatever.'
