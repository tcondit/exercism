import datetime

def add_gigasecond(datetime_obj):
    return datetime_obj + datetime.timedelta(seconds=10**9)
