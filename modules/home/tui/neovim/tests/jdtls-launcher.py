"""Check the installed POSIX launcher without starting Java or an LSP server."""

import importlib.util
import sys
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("jdtls_launcher", sys.argv[1])
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)

for version in (21, 25):
    with (
        patch.object(launcher, "get_java_major_version", return_value=version),
        patch.object(launcher.os, "execvp") as execute,
    ):
        launcher.main([
            "--jvm-arg=-Xmx6g",
            "--jvm-arg=-Djna.library.path=/test/native libraries",
            "-data", "/test/workspace with spaces",
            "-configuration", "/test/config with spaces",
        ])
    execute.assert_called_once()
    executable, argv = execute.call_args.args
    assert argv[0] == executable, "The executable must occupy argv[0], not a JVM option"
    assert "-Declipse.application=org.eclipse.jdt.ls.core.id1" in argv[1:]
    assert "-Xmx6g" in argv[1:]
    assert "-Djna.library.path=/test/native libraries" in argv[1:]
    assert argv[argv.index("-data") + 1] == "/test/workspace with spaces"
    assert argv[argv.index("-configuration") + 1] == "/test/config with spaces"
    if version >= 24:
        assert "-Djdk.xml.maxGeneralEntitySizeLimit=0" in argv[1:]
        assert "-Djdk.xml.totalEntitySizeLimit=0" in argv[1:]

print("JDT LS launcher checks passed: argv[0], XML limits, heap, native libraries, spaced paths")
