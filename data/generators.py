import numpy as numpy
import pandas as pd
import random
import string
from pyfaker import Fake
from itertools import cycle
from pathlib import Path

def categorical(prefix, num=15):
    values = ["{}_{}".format(prefix, n) for n in range(1, num)]
    return values

def rstring(as_format, num=15, str_length=4):
    ticker_length = list(range(1, str_length))
    values = [
        as_format.format(
            "".join(
                random.choices(
                    string.ascii_uppercase + string.digits,
                    k=random.choice(ticker_length),
                )
            )
        )
        for n in range(1, num)
    ]
    return values


def company_brand():
    fake = Fake()
    return fake.Company.bs()


def ticker_company_brand(num=15):
    tickers = rstring("{} US Equity", num, 5)
    out = []
    i = 0
    while i < len(tickers):
        out += [
            (tickers[i], company_brand())
            for _ in range(1, random.choice([1, 2, 3, 4, 5, 6]))
        ]
        i += 1
    return out


def period(ticker):
    qs = [("Q1", 3, 16), ("Q2", 6, 16), ("Q3", 9, 16), ("Q4", 12, 16)]
    yrs = [2000 + n for n in range(30)]
    return [
        (
            str(y) + q[0],
            "{}-{}-{}".format(y, q[1], q[2]),
            "{}-{}-{}".format(y, pq[1], pq[2] - 1),
        )
        for y, q, pq in zip(
            (y for y in yrs for _ in range(0, len(qs))),
            cycle(qs),
            cycle(qs[1:] + qs[:1]),
        )
    ]
