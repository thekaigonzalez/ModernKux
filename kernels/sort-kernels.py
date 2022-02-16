import os
import shutil

# script for copying kernels to the setup bin directory

import pathlib
import time

time.sleep(1)

print("Checking for kernel PowPCK1")

if (not pathlib.Path("../machines").exists()):
    os.mkdir("../machines")

if (pathlib.Path("powpck1/powpck1").exists()):
    shutil.copy("powpck1/powpck1", "../machines/powpck1.kernel")