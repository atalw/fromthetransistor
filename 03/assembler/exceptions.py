class Error(Exception):
    """Base class for exceptions"""
    def __init__(self, message):
        super().__init__(message)

class UndefinedName(Error):
    pass

class UndefinedOpCode(Error):
    pass

class MissingOperand(Error):
    pass

class IllegalToken(Error):
    pass

class NotSupported(Error):
    pass

class InvalidArgs(Error):
    pass
