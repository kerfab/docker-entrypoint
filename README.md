# docker-entrypoint-multiproc
## A nicely featured entrypoint shell script for Docker, for launching multiple processes within a single docker container. Production-ready & battle-tested.

### It allows you to:

- enforce and control the use of mandatory environment variables

- define optional environment variables with default values

- move files from a location to another for pre-start purposes

- build template configuration files that will be rewritten pre-start with the content of your environment variables (requires a writeable /tmp in your container)

- launch an unlimited number of processes, with optional sleep policy before starting specific processes

- implement flexible Stop conditions on crashes or processes exits: kill all the other processes (gracefully or not), restart the crashed process, ignore, execute custom command, etc.

- execute pre-start and post-start commands for additional setup processes with optional sleep policy again

- implement a global stop policy, to gracefully properly external container termination (docker stop)

- have a permanent routine which allows you to flush an unlimited number files on stdout - warning: flushed files are truncated (useful for lazy real time log extraction on stdout rather than trying to change application/servers configs to print on stdout)

- have a RESET feature, allowing you to execute specific set of commands only when you define a specific environment variable

- handles arguments on `docker run` so that you can start any other entrypoint at any time (eg: to start a shell)

The script contains internal detailed documentation explaining all the steps for exploiting the features.

### TODO (if you want to contribute):

- conditional pre-start, entrypoint and post-start pipelines rather than sleep based executions
- a support for executing specific processes under specific user ids
- a rewrite of the file replacement feature which works but could be more elegant and could avoid using /tmp
- more constants to permit an easier behavior edition on some features
