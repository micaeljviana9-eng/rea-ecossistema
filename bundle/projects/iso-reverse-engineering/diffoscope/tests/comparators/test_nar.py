#
# diffoscope: in-depth comparison of files, archives, and directories
#
# Copyright © 2024, 2026 Chris Lamb <lamby@debian.org>
# Copyright © 2022 Christopher Baines <mail@cbaines.net>
#
# diffoscope is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# diffoscope is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with diffoscope.  If not, see <https://www.gnu.org/licenses/>.

import pytest

from diffoscope.comparators.nar import NarFile

from ..utils.data import load_fixture, assert_diff
from ..utils.nonexisting import assert_non_existing
from ..utils.tools import skip_unless_tools_exist

# test1.nar and test2.nar contain a single regular file; test3.nar and
# test4.nar contain a "dir" directory holding a "text" file and a "link"
# symlink.
nar1 = load_fixture("test1.nar")
nar2 = load_fixture("test2.nar")
nar3 = load_fixture("test3.nar")
nar4 = load_fixture("test4.nar")


def test_identification(nar1):
    assert isinstance(nar1, NarFile)


def test_no_differences(nar1):
    difference = nar1.compare(nar1)
    assert difference is None


@pytest.fixture
def single_file_differences(nar1, nar2):
    return nar1.compare(nar2).details


@pytest.fixture
def differences(nar3, nar4):
    return nar3.compare(nar4).details


@skip_unless_tools_exist("guix")
def test_single_file(single_file_differences):
    # A NAR holding a single file does not record a name for it, so it is
    # named after the archive itself.
    assert single_file_differences[0].source1 == "test1"
    assert single_file_differences[0].source2 == "test2"
    assert_diff(single_file_differences[0], "text_ascii_expected_diff")


@skip_unless_tools_exist("guix")
def test_listing(differences):
    assert_diff(differences[0], "nar_listing_expected_diff")


@skip_unless_tools_exist("guix")
def test_symlinks(differences):
    assert differences[1].source1 == "dir/link"
    assert differences[1].source2 == "dir/link"
    assert differences[1].comment == "symlink"
    assert_diff(differences[1], "symlink_expected_diff")


@skip_unless_tools_exist("guix")
def test_text_file(differences):
    assert differences[2].source1 == "dir/text"
    assert differences[2].source2 == "dir/text"
    assert_diff(differences[2], "text_ascii_expected_diff")


@skip_unless_tools_exist("guix")
def test_compare_non_existing(monkeypatch, nar3):
    assert_non_existing(monkeypatch, nar3)
