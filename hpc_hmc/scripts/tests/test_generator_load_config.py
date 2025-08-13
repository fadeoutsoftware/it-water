import os
import tempfile
import json
import pytest
from hpc_hmc.scripts import generator

def make_control_file(path, params):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(params, f)

def test_loadControlFile_valid():
    params = {
        "startTime": "2025-08-01 00:00",
        "endTime": "2025-09-01 00:00",
        "periodsFileName": "periods.txt",
        "stopFileName": "stopfile"
    }
    with tempfile.TemporaryDirectory() as tmpdir:
        control_path = os.path.join(tmpdir, "control.json")
        make_control_file(control_path, params)
        loaded = generator.loadControlFile(control_path)
        assert loaded == params

def test_loadControlFile_missing_param():
    params = {
        "startTime": "2025-08-01 00:00",
        "endTime": "2025-09-01 00:00",
        "periodsFileName": "periods.txt"
        # missing stopFileName
    }
    with tempfile.TemporaryDirectory() as tmpdir:
        control_path = os.path.join(tmpdir, "control.json")
        make_control_file(control_path, params)
        with pytest.raises(RuntimeError):
            generator.loadControlFile(control_path)

def test_loadControlFile_invalid_date():
    params = {
        "startTime": "2025-08-01",
        "endTime": "2025-09-01 00:00",
        "periodsFileName": "periods.txt",
        "stopFileName": "stopfile"
    }
    with tempfile.TemporaryDirectory() as tmpdir:
        control_path = os.path.join(tmpdir, "control.json")
        make_control_file(control_path, params)
        with pytest.raises(RuntimeError):
            generator.loadControlFile(control_path)
