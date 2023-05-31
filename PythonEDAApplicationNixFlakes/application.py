#!/usr/bin/env python3
from PythonEDAApplication.pythoneda import PythonEDA

import asyncio

class NixFlakes(PythonEDA):

    def __init__(self):
        super().__init__()

if __name__ == "__main__":

    asyncio.run(NixFlakes.main())
