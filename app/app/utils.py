from operator import methodcaller

TRUE = ("1", "true", "True", "TRUE", "on", "yes")


def is_true(val: str = None) -> bool:
    return str(val) in TRUE


def split_with_comma(val: str) -> list[str]:
    return list(filter(None, map(methodcaller("strip"), val.split(","))))
