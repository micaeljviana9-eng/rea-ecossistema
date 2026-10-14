#
# diffoscope: in-depth comparison of files, archives, and directories
#
# Copyright © 2014-2015 Jérémy Bobbio <lunar@debian.org>
# Copyright © 2015-2016, 2018-2020, 2026 Chris Lamb <lamby@debian.org>
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

import datetime
import re
import struct
import tarfile

from diffoscope.difference import Difference

from .utils.file import File
from .utils.libarchive import LibarchiveContainer, list_libarchive


class TarContainer(LibarchiveContainer):
    pass


class TarFile(File):
    DESCRIPTION = "tape archives (.tar)"
    CONTAINER_CLASSES = [TarContainer]
    FILE_TYPE_RE = re.compile(r"\btar archive\b")

    def compare_details(self, other, source=None):
        libarchive_result = Difference.from_text_readers(
            list_libarchive(self.path),
            list_libarchive(other.path),
            self.path,
            other.path,
            source="file list",
        )
        if libarchive_result is not None:
            return [libarchive_result]

        # The libarchive based reader is not able to spot differences in
        # POSIX.1-2001 PAX headers. libarchive itself is capable of reading
        # this information (the archive_entry_xattr_* functions) but it
        # doesn't seem to expose the relevant functions via libarchive.ffi.
        #
        # The PAX header stores information like
        #  * very long filenames and linknames
        #  * extended attributes
        #  * POSIX ACLs
        #  * atime and ctime with sub-second resolution
        #  * GNU/Hurd translators
        #  * sparse files
        #  * files larger than 8 GiB
        #  * device major and minor numbers with more than 21 bits
        #  * uid/gid with more than 21 bits
        #
        # If libarchive is unable to see a difference between the tarballs
        # we fall back to the Python tarfile module and try to print more
        # information.
        return [
            Difference.from_text_readers(
                list_pytarfile(self.path),
                list_pytarfile(other.path),
                self.path,
                other.path,
                source="file list",
            ),
        ]


def timestamp2str(ts):
    try:
        return str(datetime.datetime.fromtimestamp(float(ts), datetime.UTC))
    except ValueError:
        return f"Unable to parse: {ts}"


def read_number(v):
    try:
        return int(v)
    except ValueError:
        return f"Unable to parse: {v}"


# from https://salsa.debian.org/josch/seedfiles-integration-tests/-/blob/main/test.py
def parse_xattr(acl):
    # see uapi/linux/posix_acl.h
    POSIX_ACL_XATTR_VERSION = 0x0002
    assert (POSIX_ACL_XATTR_VERSION,) == struct.unpack("<I", acl[:4])
    acl = acl[4:]
    assert (1,) == struct.unpack("<H", acl[:2])  # a_refcount
    (count,) = struct.unpack("<H", acl[2:4])
    assert b"\xff\xff\xff\xff" == acl[4:8]  # filler?
    # make sure that the acl minus the header is a multiple of 8
    assert len(acl) % 8 == 0
    assert count >= len(acl) / 8
    count = len(acl) / 8
    result = ""
    # see linux/posix_acl.h
    while acl:
        e_tag, e_perm, e_id = struct.unpack("<hHI", acl[:8])
        match e_tag:
            case 0x01:
                e_tag = "ACL_USER_OBJ"
            case 0x02:
                e_tag = "ACL_USER"
            case 0x04:
                e_tag = "ACL_GROUP_OBJ"
            case 0x08:
                e_tag = "ACL_GROUP"
            case 0x10:
                e_tag = "ACL_MASK"
            case 0x20:
                e_tag = "ACL_OTHER"
            case _:
                e_tag = f"Unknown e_tag: {e_tag}"
        e_perm_str = ""
        if e_perm & 0x04:
            e_perm_str += "r"
        if e_perm & 0x02:
            e_perm_str += "w"
        if e_perm & 0x01:
            e_perm_str += "x"
        if e_id + 1 == 2**32:
            e_id = "2^32-1"
        result += f"\n  {e_tag:>13} {e_perm_str:<3} {e_id}"
        acl = acl[8:]
    return result


def list_pytarfile(path):
    with tarfile.open(path) as tar:
        for member in tar:
            if not member.pax_headers:
                continue
            for k, v in sorted(member.pax_headers.items()):
                p = f"{member.name} PAX header {k}"
                match k:
                    case "GNU.sparse.numblocks":
                        yield f"{p} raw value: {v}\n"
                    case "GNU.sparse.offset":
                        yield f"{p}: {read_number(v)}\n"
                    case "GNU.sparse.numbytes":
                        yield f"{p}: {read_number(v)}\n"
                    case "GNU.sparse.size":
                        yield f"{p}: {read_number(v)}\n"
                    case "GNU.sparse.map":
                        yield f"{p} raw value: {v}\n"
                    case "GNU.sparse.major":
                        yield f"{p}: {read_number(v)}\n"
                    case "GNU.sparse.minor":
                        yield f"{p}: {read_number(v)}\n"
                    case "GNU.sparse.name":
                        yield f"{p}: {v}\n"
                    case "GNU.sparse.realsize":
                        yield f"{p}: {read_number(v)}\n"
                    case "LIBARCHIVE.creationtime":
                        yield f"{p}: {timestamp2str(v)}\n"
                    case "LIBARCHIVE.symlinktype":
                        match v:
                            case "file" | "dir":
                                yield f"{p}: {v}\n"
                            case _:
                                yield f"{p}: Unknown value: {v}"
                    case "LIBARCHIVE.xattr":
                        yield f"{p} raw value: {v}\n"
                    case "RHT.security.selinux":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.acl.access":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.acl.default":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.acl.ace":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.devmajor":
                        yield f"{p}: {read_number(v)}\n"
                    case "SCHILY.devminor":
                        yield f"{p}: {read_number(v)}\n"
                    case "SCHILY.fflags":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.dev":
                        yield f"{p}: {read_number(v)}\n"
                    case "SCHILY.ino":
                        yield f"{p}: {read_number(v)}\n"
                    case "SCHILY.nlink":
                        yield f"{p}: {read_number(v)}\n"
                    case "SCHILY.realsize":
                        yield f"{p}: {read_number(v)}\n"
                    case "SCHILY.xattr.gnu.translator":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.xattr.system.posix_acl_default":
                        yield f"{p}: {parse_xattr(v.encode(errors='surrogateescape'))}\n"
                    case "SCHILY.xattr.user":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.xattr.trusted":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.xattr.security":
                        yield f"{p} raw value: {v}\n"
                    case "SCHILY.xattr.gnu.author":
                        yield f"{p} raw value: {v}\n"
                    case "SUN.holesdata":
                        yield f"{p} raw value: {v}\n"
                    case "atime" | "ctime" | "mtime":
                        yield f"{p}: {timestamp2str(v)}\n"
                    case "gid" | "uid":
                        yield f"{p}: {read_number(v)}\n"
                    case "gname" | "uname":
                        yield f"{p}: {v}\n"
                    case "hdrcharset":
                        match v:
                            case "BINARY":
                                yield "{p}: BINARY\n"
                            case "ISO-IR 10646 2000 UTF-8":
                                yield "{p}: UTF-8\n"
                            case _:
                                yield f"{p}: Unknown value: {v}"
                    case "linkpath":
                        yield f"{p}: {v}\n"
                    case "path":
                        yield f"{p}: {v}\n"
                    case "size":
                        yield f"{p}: {read_number(v)}\n"
