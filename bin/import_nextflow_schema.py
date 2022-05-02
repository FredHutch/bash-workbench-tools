#!/usr/bin/env python3
"""Utility to set up a tool configuration based on a nextflow_schema.json file."""
import argparse
import json
import os


def get_args() -> dict:
    """Get arguments from the command line input."""

    parser = argparse.ArgumentParser(
        description="Import a tool configuration from a nextflow schema"
    )

    parser.add_argument(
        "--schema-fp",
        type=str,
        required=True,
        help="Path to nextflow_schema.json"
    )

    parser.add_argument(
        "--workflow",
        type=str,
        required=True,
        help="Workflow to run (e.g. GitHub repo)"
    )

    parser.add_argument(
        "--output",
        type=str,
        required=True,
        help="Path to output directory"
    )

    return vars(parser.parse_args())


def read_schema(schema_fp:str=None, **kwargs) -> dict:
    """Read the nextflow schema from a JSON file."""

    assert os.path.exists(schema_fp), f"File does not exist: {schema_fp}"

    with open(schema_fp, "r") as handle:

        try:
            return json.load(handle)
        except Exception as e:
            raise Exception(f"Error parsing file as JSON {schema_fp}: {e}")


def parse_config(schema:dict, workflow:str) -> dict:
    """Parse a bash-workbench config from a nextflow schema."""

    config = dict(
        name=schema["title"],
        description=schema["description"],
        args=dict()
    )

    for kw, arg in parse_args(schema["definitions"]):
        config["args"][kw] = arg

    # Add the argument for the workflow repository
    config["args"]["workflow_repo"] = dict(
        name="Workflow Repository",
        description="Location of workflow repository to run",
        wb_type="string",
        wb_env="WORKFLOW_REPO",
        default=workflow
    )

    return config


def parse_args(args):
    """Parse the JSON schema object for workflow parameters."""

    allowed_types = [
        "string",
        "password",
        "file",
        "folder",
        "select",
        "integer",
        "float",
        "bool"
    ]

    type_map = dict(
        boolean="bool"
    )

    assert isinstance(args, dict)

    for kw, val in args.items():

        if val["type"] == "object":
            for k, v in parse_args(val["properties"]):
                yield k, v

        else:

            arg = dict()

            if "help_text" in val:
                arg["help"] = f"{val.get('description', '')}\n      {val.get('help_text', '')}"
            else:
                arg["help"] = val["description"]

            if "default" in val:
                arg["default"] = val["default"]

            if "enum" in val:

                arg["wb_type"] = "select"
                arg["wb_choices"] = val["enum"]

            else:

                wb_type = type_map.get(val["type"], val["type"])

                assert wb_type in allowed_types, f"Can not use type '{wb_type}'"

                arg["wb_type"] = wb_type

            yield kw, arg


def import_nextflow_schema(schema:dict, output:str, workflow:str, **kwargs) -> None:
    """Convert the nextflow schema format to the assets needed for a bash-workbench tool."""

    # Generate the config json
    config = parse_config(schema, workflow)

    # Make sure that `outdir` is configured
    assert "outdir" in config, "Expected param was not found: outdir"

    # Delete the outdir, since the run script will set it at runtime
    del config["outdir"]

    # Get the path of the directory containing this script
    script_dir = os.path.abspath( os.path.dirname( __file__ ) )

    # There should be another file in that folder named "run.sh"
    run_fp = os.path.join(script_dir, "run.sh")
    assert os.path.exists(run_fp), f"Could not find 'run.sh' in {script_dir}"

    # If the output folder does not exist
    if not os.path.exists(output):

        # Make it
        os.makedirs(output)

    # The output folder must be a folder
    assert os.path.isdir(output), f"Path must be a folder: '{output}'"

    # Copy the run script
    with open(run_fp, 'r') as handle_i, open(os.path.join(output, "run.sh"), "w") as handle_o:
        handle_o.write(handle_i.read())

    # Write out the config
    with open(os.path.join(output, "config.json"), "w") as handle_o:
        json.dump(config, handle_o, indent=4)

if __name__ == "__main__":

    # Get arguments from the command line
    print("Getting arguments")
    args = get_args()

    # Read the schema
    print("Reading the schema")
    schema = read_schema(**args)

    # Import the nextflow schema and write out
    print("Reconfiguring for the BASH workbench")
    import_nextflow_schema(schema=schema, **args)

    print("Done")