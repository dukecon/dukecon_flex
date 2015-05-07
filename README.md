# DukeCon-Client: Flex

In order to get stated with building FLEX application with Maven, please visit:
https://cwiki.apache.org/confluence/display/FLEX/Preparing+FDKs+for+Maven+builds

## Short Version:
Not all resources needed by the build are available via Maven. Adobe
has been quite restrictive with some of its resources.

We have therefore developed a Maven extension that should hide all the
trouble of getting your environment setup. As this has not yet been
released, you have to build it, but it shouldn't be that hard to do.

One thing you do need though in addition to this in order to run the
Flex unit-tests, is a working flashplayer binary in your PATH.

