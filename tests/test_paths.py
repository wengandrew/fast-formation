"""
Check that the paths are configured correctly
"""

import pytest
import yaml
from pathlib import Path


@pytest.fixture
def paths():

    paths = yaml.load(open('paths.yaml', 'r'), Loader=yaml.FullLoader)

    return paths


def test_data_path(paths):

    assert Path(paths['data']).exists()


def test_output_path(paths):

    assert Path(paths['outputs']).exists()


def test_document_path(paths):

    assert Path(paths['documents']).exists()



