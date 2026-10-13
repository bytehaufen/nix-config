import json
import os
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET


def prepare(config):
    source = Path(config["source"])
    directory = Path(config["directory"])
    tree = ET.parse(source)
    launch = tree.getroot()
    if launch.tag != "launchConfiguration" or launch.get("type") != "org.eclipse.pde.ui.RuntimeWorkbench":
        raise ValueError("Select an org.eclipse.pde.ui.RuntimeWorkbench .launch file")

    def attribute(key):
        matches = [node for node in launch if node.get("key") == key]
        if len(matches) > 1:
            raise ValueError("Duplicate launch attribute: " + key)
        return matches[0] if matches else None

    projects = {}
    project_name = None
    for path in config["projects"]:
        project = ET.parse(Path(path) / ".project").getroot()
        name = project.findtext("name")
        if not name:
            raise ValueError("Missing Eclipse project name in " + path + "/.project")
        if name in projects:
            raise ValueError("Duplicate selected Eclipse project name: " + name)
        projects[name] = Path(path).resolve()
        if project_name is None and any(n.text == "org.eclipse.jdt.core.javanature" for n in project.findall("natures/nature")):
            project_name = name
    if project_name is None:
        raise ValueError("No selected Java project; add its project directory to javaConfig.json")

    jre = attribute("org.eclipse.jdt.launching.JRE_CONTAINER")
    container = jre.get("value", "") if jre is not None else ""
    name = container.rsplit("/", 1)[-1] if container else None
    runtimes = [runtime for runtime in config["runtimes"] if runtime.get("name") == name] if name else [runtime for runtime in config["runtimes"] if runtime.get("default") is True]
    if len(runtimes) != 1:
        raise ValueError("Unknown or ambiguous launch JRE " + (name or "default") + "; configure vim.g.pde_java_runtimes or activate Home Manager")
    java = Path(runtimes[0]["path"]) / "bin/java"
    if not java.is_file() or not os.access(java, os.X_OK):
        raise ValueError("Launch JRE executable missing: " + str(java))

    append = attribute("org.eclipse.debug.core.appendEnvironmentVariables")
    if append is not None and append.get("value", "").lower() == "false":
        raise ValueError("appendEnvironmentVariables=false is unsupported; launch requires inherited environment")
    environment = attribute("org.eclipse.debug.core.environmentVariables")
    if environment is not None:
        for entry in environment.findall("mapEntry"):
            key = entry.get("key", "<missing key>")

            def expand(match):
                variable = match.group(1)
                if variable == "workspace_loc":
                    return config["workspace"]
                if variable.startswith("workspace_loc:/"):
                    name, _, relative = variable[len("workspace_loc:/"):].partition("/")
                    if name not in projects:
                        raise ValueError("Environment " + key + ": missing selected project " + name)
                    return str(projects[name] / relative)
                if variable.startswith("env_var:"):
                    name = variable[len("env_var:"):]
                    if name not in os.environ:
                        raise ValueError("Environment " + key + ": missing environment variable " + name)
                    return os.environ[name]
                raise ValueError("Environment " + key + ": unsupported variable " + variable)

            value = re.sub(r"\$\{([^{}]*)\}", expand, entry.get("value", ""))
            if "${" in value:
                raise ValueError("Environment " + key + ": unresolved variable expression")
            entry.set("value", value)

    def override(tag, key, value):
        node = attribute(key)
        if node is None:
            node = ET.SubElement(launch, tag, key=key)
        node.tag = tag
        node.set("value", value)

    for key, child in (("location", "workspace"), ("configLocation", "configuration")):
        override("stringAttribute", key, str(directory / child))
    for key in ("useDefaultConfigArea", "clearws", "clearwslog", "clearConfig", "askclear"):
        override("booleanAttribute", key, "false")
    directory.mkdir(parents=True, exist_ok=True)
    (directory / "workspace").mkdir(exist_ok=True)
    (directory / "configuration").mkdir(exist_ok=True)
    copy = directory / source.name
    tree.write(copy, encoding="UTF-8", xml_declaration=True)
    return {"launch": str(copy), "javaExec": str(java), "projectName": project_name}


if __name__ == "__main__":
    try:
        result = prepare(json.load(sys.stdin))
    except ET.ParseError:
        sys.exit("Malformed launch or selected .project XML; inspect those files")
    except OSError as error:
        sys.exit("Cannot read/write launch preparation files: " + (error.strerror or "I/O error") + " (" + str(error.filename) + ")")
    except (ValueError, KeyError, TypeError) as error:
        sys.exit(str(error))
    print(json.dumps(result))
