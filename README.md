# docker-entrypoint-multiproc
## A nicely featured entrypoint battle-tested shellscript, for launching multiple processes within a single docker container.

### It allows you to:

- enforce and control the use of mandatory environment variables

- define optional environment variables with default values

- move files from a location to another for pre-start purposes

- build template configuration files that will be rewritten pre-start with the content of your environment variables

- launch an unlimited number of processes, with optional sleep policy before starting specific processes

- implement flexible Stop conditions on crashes or processes exits: kill all the other processes (gracefully or not), restart the crashed process, ignore, etc.

- execute pre-start and post-start commands for additional setup processes with optional sleep policy again

- implement a global stop policy, to gracefully properly external container termination (docker stop)

- have a permanent routine which allows you to flush an unlimited number files on stdout - warning: flushed files are truncated (useful for lazy real time log extraction on stdout rather than trying to change application/servers configs to print on stdout)

- have a RESET feature, allowing you to execute specific set of commands only when you define a specific environment variable

The script contains internal detailed documentation explaining all the steps for exploiting the features.
