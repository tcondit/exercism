import string


def word_count(words):
    words = words.decode('utf-8')
    for c in words:
        if not c.isalnum():
            words = words.replace(c, ' ')

    count = {}
    for word in words.lower().split(' '):
        if len(word) == 0:
            continue
        if word in count:
            count[word] += 1
        else:
            count[word] = 1
    return(count)
