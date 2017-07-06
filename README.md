# docker-entrypoint-multiproc
##A nicely featured shellscript, battle-tested for launching multiple processes within a single docker container.

#It allows you to:

- enforce and control the use of mandatory environment variables

- define optional environment variables with default values

- move files from a location to another for pre-start purposes

- build template configuration files that will be rewritten pre-start with the content of your environment variables

- implement flexible Stop conditions on crashes or process exit: kill all the other processes gracefully or not, restart the crashed process, ignore the crash...

- have an unlimited number of entrypoints with optional sleep policy before starting specific processes

- execute pre-start and post-start commands for additional setup processes with optional sleep policy again

- have a global stop policy, to handle graceful external container termination (docker stop)

- have a permanent routine which allows you to flush an unlimited number files on stdout - warning: flushed files are truncated (useful for lazy real time log extraction on stdout)

- have a RESET feature, allowing you to execute specific set of commands only when you define a specific environment variable


