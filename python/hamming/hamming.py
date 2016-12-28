def distance(strand1, strand2):

    if len(strand1) != len(strand2):
        raise ValueError

    distance = 0
    for i in range(len(strand1)):
        if strand1[i].upper() != strand2[i].upper():
            distance += 1
    return distance
