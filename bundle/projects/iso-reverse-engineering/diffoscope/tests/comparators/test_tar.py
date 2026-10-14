#
# diffoscope: in-depth comparison of files, archives, and directories
#
# Copyright © 2015 Jérémy Bobbio <lunar@debian.org>
# Copyright © 2015-2017, 2020, 2026 Chris Lamb <lamby@debian.org>
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

import gzip
import os.path
import pytest
import struct

from diffoscope.config import Config
from diffoscope.comparators.tar import TarFile
from diffoscope.comparators.missing_file import MissingFile
from diffoscope.comparators.utils.specialize import specialize
from diffoscope.comparators.binary import FilesystemFile

from ..utils.data import load_fixture, get_data, assert_diff
from ..utils.nonexisting import assert_non_existing

tar1 = load_fixture("test1.tar")
tar2 = load_fixture("test2.tar")


def test_identification(tar1):
    assert isinstance(tar1, TarFile)


def test_no_differences(tar1):
    difference = tar1.compare(tar1)
    assert difference is None


@pytest.fixture
def differences(tar1, tar2):
    return tar1.compare(tar2).details


def test_listing(differences):
    expected_diff = get_data("tar_listing_expected_diff")
    assert differences[0].unified_diff == expected_diff


def test_symlinks(differences):
    assert differences[2].source1 == "dir/link"
    assert differences[2].source2 == "dir/link"
    assert differences[2].comment == "symlink"
    expected_diff = get_data("symlink_expected_diff")
    assert differences[2].unified_diff == expected_diff


def test_text_file(differences):
    assert differences[1].source1 == "dir/text"
    assert differences[1].source2 == "dir/text"
    expected_diff = get_data("text_ascii_expected_diff")
    assert differences[1].unified_diff == expected_diff


def test_compare_non_existing(monkeypatch, tar1):
    assert_non_existing(monkeypatch, tar1)


no_permissions_tar = load_fixture("no-perms.tar")

# Reported as Debian #797164. This is a good way to notice if we unpack directories
# as we won't be able to remove files in one if we don't have write permissions.


def test_no_permissions_dir_in_tarball(monkeypatch, no_permissions_tar):
    # We want to make sure OSError is not raised.
    # Comparing with non-existing file makes it easy to make sure all files are unpacked
    monkeypatch.setattr(Config(), "new_file", True)
    no_permissions_tar.compare(MissingFile("/nonexistent", no_permissions_tar))


# The result of
#    $ tar --format=pax --no-recursion -C /var/log -cf journal.tar ./journal
# once with and once without the --xattrs option
tar_acl_bytes = bytes.fromhex(
    "1f8b080085ad436a02ffedd44f4bc3301806f02813a5273f42bf8069fef6ad87"
    "9dbc4cf02078f224a1ad30e9ac3419d44faf2fdb4419a2286e179f1f94276d42"
    "d2439fcae23a8cb33634ed108b877e393c864efc31c54ae756c9b6535947423b"
    "6b4a22e734afd39ab411f928f660195318f855c4ff64551ed27cd14e35558648"
    "3932d2581e91b72ee3d97a3d5b92f59a942269cfb5afac336556f9fce6627679"
    "752bc790d220e3734ced423ef5713ede85bae3ab6e639c1ef23907e258bcb089"
    "385ae509e7849f9f6eeef34d6655f9cda64d7b1f965dfad9ae023e27df4a5fec"
    "ee0caeb821ef3ff65e13775ebddbeabf2d9d16b9df67ff87be4f5fad5b7f87cd"
    "d98efe910000000000000000000000000000000000bff10adb0252ab00280000"
)


tar_noacl_bytes = bytes.fromhex(
    "1f8b0800b4ad436a02ffedd43d6a0331108661d53ec55ec0bbfa19699cc2bdcb"
    "5c41c45bc4c459d85d83737b0f0e263f458a101b82dfa719a11990407c6abbc7"
    "7adcf475db8f53b71b0ee36b7d717fcc9b2272aee67bf55ec50549b1a88a049b"
    "0b41bdbae6e86ee030cd75b4abb8fb947c53e7e77dbf0eba8aaa5e34b631d94a"
    "739285759fdebb4553b657f1daa687905749625938fc7bed25f4ddf5ceb08447"
    "cdf973ee838a7ee4dff6bee63f1509aec9b7ccff380cf34f73d3db34f7fbedf2"
    "4a7f24000000000000000000000000f01b278df8083500280000"
)

# We run tar with --clamp-mtime --mtime=0 but the ctime and atime
# will still be stored in pax headers. Re-create like this:
#    $ tar --clamp-mtime --mtime=0 --format=pax --no-recursion -cf bin1.tar ./bin
#    $ touch ./bin
#    $ tar --clamp-mtime --mtime=0 --format=pax --no-recursion -cf bin2.tar ./bin

tar_before_bytes = bytes.fromhex(
    "1f8b0800000000000003edd3cd0a8240148661d75d8557a067fe6dd1be65b760"
    "256450411a74f94d861006b508b3c5fb6c0ecc37301f0c27cb57e5755995dbea"
    "dce4ebfa988c40226f6d37a3e1140936514e6b71de191bcf95846092f43a4699"
    "a14bd396e758e5176ffd212369d9d6876aa142a10be38cf299b7f107bcf6c52c"
    "a69b97d4e898cadccea6ee8eef65f7a5cfc77da35bf1e0ee530527cfb337d87f"
    "25da25a91bb7d643bffffb53b3d9bdb9f7290700000000000000000000000026"
    "7003acf6139900280000"
)

tar_after_bytes = bytes.fromhex(
    "1f8b0800000000000003edd3cd0a8240148661d75d8557a0f3e39971d3be65b7"
    "60266450811678f98d861042b508b3c5fb6c3e983370cee64bd26dd16daa625f"
    "356dbaabcfd10c54e0b26cc8609a4af92cd2628c1227360bef5a796fa3b89be3"
    "98a95b7b2d9a70ca2f76fd21abe2e25a9faab5f6b9c9ad5897275a7b63c439b7"
    "0ad3f2f574e9dbf1bda42f7d3aef8ea1e25efad45ed4738e26fdd7ca4814cbbc"
    "673d8cfd3f5edaf2f0e6dfa739000000000000000000000000b0803be9796d3f"
    "00280000"
)


# Generates a PAX format tarball with a single entry which has the GNU/Hurd
# translator given in the content argument attached to it in a PAX header
def generate_pax(
    name, mode, type, linktarget=None, major=None, minor=None, content=None
):
    entries = []
    if content is not None:
        content = "SCHILY.xattr.gnu.translator=" + content
        # In the beginning the decimal length of the field is recorded.
        # But the length includes the length of the number itself.
        # Luckily we only need to support decimal numbers with two digits.
        assert 9 < len(content) + 4 < 100
        dirname, basename = os.path.split(name)
        paxname = dirname + "/PaxHeaders/" + basename
        content = f"{len(content) +4} {content}\n"
        entries.append((paxname, 0, "x", None, None, None, content))
    entries.append((name, mode, type, linktarget, major, minor, None))

    mtime = int(1612543740)  # an arbitrary reproducible date
    devtar = b""
    for file in entries:
        fname, mode, type, linktarget, major, minor, content = file
        assert len(fname) <= 100
        buf = struct.pack(
            "@100s8s8s8s12s12s8s1s100s6s2s32s32s8s8s155s12s",
            fname.encode(),
            f"{mode:07o}".encode(),
            b"0" * 7,
            b"0" * 7,
            f"{len(content) if content is not None else 0:011o}".encode(),
            f"{0 if type == 'x' else mtime:011o}".encode(),
            b" " * 8,
            type.encode(),
            linktarget.encode() if linktarget is not None else b"",
            b"ustar",
            b"00",
            b"",
            b"",
            (f"{major:07o}" if major is not None else "").encode(),
            (f"{minor:07o}" if minor is not None else "").encode(),
            b"",
            b"",
        )
        chksum = 256 + sum(struct.unpack_from("148B8x356B", buf))
        buf = buf[:-364] + f"{chksum:06o}\0".encode() + buf[-357:]
        devtar += buf
        if content is not None:
            devtar += struct.pack("@512s", content.encode())
    return struct.pack("@10240s", devtar)


def tar_fixture(content, prefix):
    @pytest.fixture
    def pax_tar(tmp_path, tar1, tar2):
        match prefix:
            case "test1":
                tar = tar1
            case "test2":
                tar = tar2
            case _:
                raise Exception(f"Invalid prefix: {prefix}")
        tar_path = tmp_path / f"{prefix}.tar"
        with open(tar_path, "wb") as t_fp:
            t_fp.write(content)
            with open(tar.path, "rb") as r_fp:
                t_fp.write(bytes(r_fp.read()))
        return specialize(FilesystemFile(str(tar_path)))

    return pax_tar


tar_acl = tar_fixture(gzip.decompress(tar_acl_bytes), "test1")
tar_noacl = tar_fixture(gzip.decompress(tar_noacl_bytes), "test2")

tar_before = tar_fixture(gzip.decompress(tar_before_bytes), "test1")
tar_after = tar_fixture(gzip.decompress(tar_after_bytes), "test2")


# The translator of tar_fd1_translator is wrong -- don't do this at home, kids!
tar_fd0_translator = tar_fixture(
    generate_pax(
        name="./dev/fd0", mode=0o640, type="0", content="/hurd/storeio\0fd0\0"
    ),
    "test1",
)
tar_fd1_translator = tar_fixture(
    generate_pax(
        name="./dev/fd0", mode=0o640, type="0", content="/hurd/storeio\0fd1\0"
    ),
    "test2",
)


def test_identification(
    tar_acl,
    tar_noacl,
    tar_before,
    tar_after,
    tar_fd0_translator,
    tar_fd1_translator,
):
    assert isinstance(tar_acl, TarFile)
    assert isinstance(tar_noacl, TarFile)
    assert isinstance(tar_before, TarFile)
    assert isinstance(tar_after, TarFile)
    assert isinstance(tar_fd0_translator, TarFile)
    assert isinstance(tar_fd1_translator, TarFile)


@pytest.fixture
def differences_acl(tar_acl, tar_noacl):
    return tar_acl.compare(tar_noacl).details


def test_listing_acl(differences_acl):
    assert_diff(differences_acl[0], "tar_acl_diff")


@pytest.fixture
def differences_atime(tar_before, tar_after):
    return tar_before.compare(tar_after).details


def test_listing_atime(differences_atime):
    assert_diff(differences_atime[0], "tar_atime_diff")


@pytest.fixture
def differences_translator(tar_fd0_translator, tar_fd1_translator):
    return tar_fd0_translator.compare(tar_fd1_translator).details


def test_listing_translator(differences_translator):
    assert_diff(differences_translator[0], "tar_translator_diff")
