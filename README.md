Packaging your project
=============================================
Running `./alan.sh build` in your project produces a project.definition file.
This is packaged together with a deployment configuration (and sometimes instance data), to create an 'image'.
To simplify the step involved here, you can use the package script:

```
./package.sh project/devenv/output/project.definition deployments/demo/
```



Creating migrations
=============================================
Data migration is currently only available for "datastore" systems.
To create such a migration, you need to set up a separate working environment.

Example layout for a migrations ("dataenv") environment:

migrations/
  \_ versions.json
  \_ from_version_x/
        \_ build.json
        \_ migration.alan
        \_ regexp.alan
        \_ from/
              \_ application.alan
        \_ to/
              \_ application.alan(.link)

The versions.json would be the same as the one in your project,
but with only the "datastore" system type in addition to the platform version.
You bootstrap this environment using `./alan.sh fetch dataenv`.

To build a migration, run `./alan.sh validate` from the definition directory.
Run `./alan.sh build` from the migrations directory to build all migrations.
This will produce a "migration" package that can be used in a deployment.
The datastore probably also provides additional scripts to generate and work with the migration. Please refer to its documentation for more information.


## Using a migration in a deployment
In your deployment.alan, for the system you want to migrate,
change `from local` to something like this (depending on the situation):

```
from remote
	socket "127.0.0.1" : 12345
	stack "demo"
	system "urenregistratie_server"
	migrate
```

If you run package.sh with this deployment, it will fail and tell you where it expects the migration package. It's something like:

```
<deployment>/instances/<system-name>.migration
```

> Note: the "migrate" keyword is optional,
  e.g. to use data from a remote stack without a migration.



Running an image on the server
=============================================
Once you have a working server, you're ready to run an image on it.

One application server can manage multiple applications (aka "stacks").
You talk to the server using the application-client,
which you can ask for `--help` and it will tell you all it can do.

Perhaps the easiest approach at first is to re-use the "demo" stack name and replace it every time you want to run something:

```
./runenv/platform/operating-system/application-client 127.0.0.1 12345 --batch replace "demo" image
```
