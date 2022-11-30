
import subprocess
import os

instance = "flat1000_50_0.col"

#instance = "C2000.5.col"


name_subgraph = "flat1000_50_0.colw10"

# while( not os.path.exists(name_subgraph + "_results.txt")):
subprocess.run(["HEAD/head", name_subgraph, "1000", "-s 10", "-r -1", "-i 8000",
                    "-o" +  "test.txt"])
