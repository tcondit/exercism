import datetime

GIGASECOND = 1000000000

def add_gigasecond(datetime_obj):
    return datetime_obj + datetime.timedelta(seconds=GIGASECOND)
