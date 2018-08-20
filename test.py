#!/usr/bin/python3

# Starts a server at 49000 and deploys to it twice,
# once with the default deployment, once with the test deployment
# ensuring deployment and replacement are functional.

import subprocess
import shutil
import sys
import time

platform = 'linux-x64'
if sys.platform == 'darwin':
    platform = 'darwin-x64'

try:
    print("Bootstrapping...")
    cmd = 'bash -c "mkdir -p appsrv/data appsrv/runenv/image && curl -s https://dist.m-industries.com/share/image/image-11-{}.tar.gz | tar xzf - -C appsrv/runenv/image"'.format(platform)
    subprocess.run(cmd, shell=True, check=True)
    print()

    print("Running host...")
    appsrv = subprocess.Popen(
        [
            "./runenv/image/application-server",
            "127.0.0.1",
            "49000"
        ],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        close_fds=True,
        cwd="appsrv"
    )
    print()

    print("Test base deployment")
    res = subprocess.run(
        [
            "./.alan/alan-tools/application-client",
            "127.0.0.1",
            "49000",
            "--batch",
            "upload",
            "default",
            "dist/default.image"
        ],
        stdin=subprocess.DEVNULL
    )
    time.sleep(1)
    print()
    if res.returncode != 0:
        raise subprocess.CalledProcessError

    print("Test replacement")
    res = subprocess.run(
        [
            "./.alan/alan-tools/application-client",
            "127.0.0.1",
            "49000",
            "--batch",
            "replace",
            "default",
            "dist/test.image"
        ],
        stdin=subprocess.DEVNULL,
        check=True
    )
    time.sleep(1)
    print()
    if res.returncode != 0:
        raise subprocess.CalledProcessError

except Exception as e:
    print("-*- failure -*-")
    print(e)
    sys.exit(1)

finally:
    print("Cleaning up")
    time.sleep(1.5)
    appsrv.terminate()
    appsrv.wait()
    shutil.rmtree("appsrv")
