import os
import tempfile
import json
from hpc_hmc.scripts import generator

def make_control_file(path, params):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(params, f)

def test_stop_file_generation():
    params = {
        "startTime": "2025-08-01 00:00",
        "endTime": "2025-09-01 00:00",
        "periodsFileName": "periods.txt",
        "stopFileName": "stopfile"
    }
    with tempfile.TemporaryDirectory() as tmpdir:
        control_path = os.path.join(tmpdir, "control.json")
        periods_path = os.path.join(tmpdir, "periods.txt")
        stop_path = os.path.join(tmpdir, "stopfile")
        params["periodsFileName"] = periods_path
        params["stopFileName"] = "stopfile"
        make_control_file(control_path, params)
        # Patch parse_args to use our control file
        args = type("Args", (), {"controlFile": control_path})()
        generator.main.__globals__["parse_args"] = lambda: args
        generator.main()
        assert os.path.exists(stop_path)
        with open(stop_path, "r", encoding="utf-8") as f:
            assert f.read() == "STOP"
