import os
import json
import tempfile
from datetime import datetime
from hpc_hmc.scripts import generator

def generate_control_file(tmpdir, filename, start_time, end_time, periods_file, stop_file):
    control_path = os.path.join(tmpdir, filename)
    data = {
        "startTime": start_time,
        "endTime": end_time,
        "periodsFileName": periods_file,
        "stopFileName": stop_file
    }
    with open(control_path, "w", encoding="utf-8") as f:
        json.dump(data, f)
    return control_path


def create_control_file(path, start_time, end_time, periods_file, stop_file):
    data = {
        "startTime": start_time,
        "endTime": end_time,
        "periodsFileName": periods_file,
        "stopFileName": stop_file
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f)

def read_output_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.readlines()

def test_generatePeriods_creates_file_and_returns_end():
    start_time = "2025-08-01 00:00"
    with tempfile.TemporaryDirectory() as tmpdir:
        periods_path = os.path.join(tmpdir, "periods.txt")
        oEnd = generator.generatePeriods(periods_path, start_time)
        assert oEnd == datetime(2025, 9, 1, 0, 0)
        with open(periods_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        assert lines[0].strip() == "TimeStart            TimeEnd              Days"
        assert lines[1].strip() == "2025-08-01T00:00     2025-09-01T00:00     31"

def test_generator_creates_correct_output_and_updates_control():
    with tempfile.TemporaryDirectory() as tmpdir:
        output_path = os.path.join(tmpdir, "output.txt")
        stop_path = os.path.join(tmpdir, "stop.txt")
        control_path = generate_control_file(
            tmpdir,
            "my_control_file.json",
            "2025-08-01 00:00",
            "2025-09-01 00:00",
            output_path,
            "stop.txt"
        )
        args = type("Args", (), {"controlFile": control_path})()
        generator.main.__globals__["parse_args"] = lambda: args
        generator.main()
        lines = read_output_file(output_path)
        assert lines[0].strip() == "TimeStart            TimeEnd              Days"
        assert lines[1].strip() == "2025-08-01T00:00     2025-09-01T00:00     31"
        with open(control_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        assert data["startTime"] == "2025-09-01 00:00"
        os.remove(control_path)

def test_generator_handles_december():
    with tempfile.TemporaryDirectory() as tmpdir:
        output_path = os.path.join(tmpdir, "output.txt")
        stop_path = os.path.join(tmpdir, "stop.txt")
        control_path = generate_control_file(
            tmpdir,
            "my_control_file_december.json",
            "2025-12-01 00:00",
            "2026-01-01 00:00",
            output_path,
            "stop.txt"
        )
        args = type("Args", (), {"controlFile": control_path})()
        generator.main.__globals__["parse_args"] = lambda: args
        generator.main()
        lines = read_output_file(output_path)
        assert lines[1].strip() == "2025-12-01T00:00     2026-01-01T00:00     31"
        with open(control_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        assert data["startTime"] == "2026-01-01 00:00"
        os.remove(control_path)

def test_generator_handles_february_leap_year():
    with tempfile.TemporaryDirectory() as tmpdir:
        output_path = os.path.join(tmpdir, "output.txt")
        stop_path = os.path.join(tmpdir, "stop.txt")
        control_path = generate_control_file(
            tmpdir,
            "my_control_file_feb_leap.json",
            "2024-02-01 00:00",
            "2024-03-01 00:00",
            output_path,
            "stop.txt"
        )
        args = type("Args", (), {"controlFile": control_path})()
        generator.main.__globals__["parse_args"] = lambda: args
        generator.main()
        lines = read_output_file(output_path)
        assert lines[1].strip() == "2024-02-01T00:00     2024-03-01T00:00     29"
        with open(control_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        assert data["startTime"] == "2024-03-01 00:00"
        os.remove(control_path)
