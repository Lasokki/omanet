#!/usr/bin/env python3
"""
Creates a secret.yml file to complement the existing settings.yml with instance
specific settings.
"""

import os
import stat
import shlex
import argparse
import subprocess
from collections import namedtuple

def cmd(cmdline):
    split_cmd = shlex.split(cmdline)
    proc = subprocess.run(split_cmd, stdout=subprocess.PIPE)
    result = ProcResult(stdout=proc.stdout, retval=proc.returncode)
    return result

ProcResult = namedtuple('ProcResult', ['stdout', 'retval'])

SETTINGS_TEMPLATE = """
database:
  user: "_env:PGUSER:{db_user}"
  password: "_env:PGPASS:{db_password}"

mail:
  emailServer: "{mail_host}"
  emailPort: {mail_port}
  emailUsername: "{mail_user}"
  emailPassword: "{mail_password}"
"""
DEFAULT_DB_USER = "omanet_dev"
DEFAULT_MAIL_PORT = 587 # ssl

SECRET_FILENAME = os.path.join("config", "secret.yml")

pwgen = cmd("pwgen -s 64 1")
# https://docs.python.org/3/library/locale.html
# TODO: Get decoding automatically
generated_password = pwgen.stdout.strip().decode("utf-8")

parser = argparse.ArgumentParser(description="Initialise the service by generating an instance specifig settings file.")
parser.add_argument("--db-user", dest="db_user", type=str, default=DEFAULT_DB_USER)
parser.add_argument("--db-password", dest="db_password", type=str, default=generated_password)
parser.add_argument("--mail-host", dest="mail_host", type=str, default="")
parser.add_argument("--mail-port", dest="mail_port", type=int, default=DEFAULT_MAIL_PORT)
parser.add_argument("--mail-user", dest="mail_user", type=str, default="")
parser.add_argument("--mail-password", dest="mail_password", type=str, default="")
args = parser.parse_args()

db_user = args.db_user
db_password = args.db_password
mail_host = args.mail_host
mail_port = args.mail_port
mail_user = args.mail_user
mail_password = args.mail_password

settings_text = SETTINGS_TEMPLATE.format(
    db_user=db_user,
    db_password=db_password,
    mail_host=mail_host,
    mail_port=mail_port,
    mail_user=mail_user,
    mail_password=mail_password,
)

# Output the values into secret.yml and only set read access for the owner
print("Writing to {secret_filename}:".format(secret_filename=SECRET_FILENAME))
with open(SECRET_FILENAME, "w") as secret_fd:
    print(settings_text)
    secret_fd.write(settings_text)

os.chmod(SECRET_FILENAME, stat.S_IRUSR)

